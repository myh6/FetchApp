//
//  RecipeImageDataLoaderTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation
import XCTest
import Fetch

final class RemoteRecipeImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURL.isEmpty)
    }
    
    func test_loadImageDataFromURL_performsURLRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLRequestTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in}
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url, url])
    }
    
    func test_loadImageDataFromURL_delviersConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()
        
        
        expect(sut, toCompleteWith: .failure(RemoteRecipeImageDataLoader.Error.connectivity)) {
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
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty)
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        let anyError = anyNSError()
        
        var received = [RecipeImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(withStatusCode: 400, data: Data())
        client.complete(with: anyError)
        
        XCTAssertTrue(received.isEmpty)
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterSUTHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteRecipeImageDataLoader? = RemoteRecipeImageDataLoader(client: client)
        
        var capturedResult = [RecipeImageDataLoader.Result]()
        
        _ = sut?.loadImageData(from: anyURL()) { result in
            capturedResult.append(result)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRecipeImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteRecipeImageDataLoader, toCompleteWith expectedResult: RecipeImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: url) { receivedResult in
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
