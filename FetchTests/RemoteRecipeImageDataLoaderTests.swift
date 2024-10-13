//
//  RecipeImageDataLoaderTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation
import XCTest
import Fetch

protocol RecipeImageDataLoaderTask {
    func cancel()
}

protocol RecipeImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageDate(from url: URL, completion: @escaping (Result) -> Void) -> RecipeImageDataLoaderTask
}

class RemoteRecipeImageDataLoader {
    let client: HTTPClient
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200 && !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(RemoteRecipeImageDataLoader.Error.invalidData))
                }
            case let .failure(error): completion(.failure(error))
            }
        }
    }
}

final class RemoteRecipeImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURL.isEmpty)
    }
    
    func test_loadImageDataFromURL_performsURLRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLRequestTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in}
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url, url])
    }
    
    func test_loadImageDataFromURL_delviersErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "any error", code: 0)
        
        
        expect(sut, toCompleteWith: .failure(clientError)) {
            client.complete(with: clientError)
        }
    }
    
    func test_loadImageDataFromURL_deliverInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteRecipeImageDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteRecipeImageDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: Data(), at: 0)
        }
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRecipeImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        private var messages = [(requestedURL: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURL: [URL] {
            messages.map(\.requestedURL)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURL[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func expect(_ sut: RemoteRecipeImageDataLoader, toCompleteWith expectedResult: RecipeImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected to complete with \(expectedResult), but received \(receivedResult) instead.")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
