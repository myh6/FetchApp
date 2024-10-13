//
//  FetchTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/11.
//
 
import XCTest
import Fetch

final class RemoteRecipeLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURL.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURL, [url])
    }
    
    func test_loadTwice_reqestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURL, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(RemoteRecipeLoader.Error.connectivity)) {
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: .failure(RemoteRecipeLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: makeInvalidJSON(), at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteRecipeLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: makeInvalidJSON())
        }
    }
    
    func test_load_deliversNoItemOn200HTTPURLResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            client.complete(withStatusCode: 200, data: makeEmptyJSON())
        }
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let (item, data) = makeItem(photoURLLarge: anyURL(), photoURLSmall: anyURL(), sourceURL: anyURL(), youtubeURL: anyURL())
        
        expect(sut, toCompleteWith: .success([item])) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliversResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteRecipeLoader? = RemoteRecipeLoader(client: client, url: anyURL())
        
        var capturedResult = [RemoteRecipeLoader.Result]()
        sut?.load { result in
            capturedResult.append(result)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeInvalidJSON() -> Data {
        let data = makeFeedDict()
        return makeItemJSON([data])
    }
    
    private func makeEmptyJSON() -> Data {
        return makeItemJSON([])
    }
    
    private func makeItem(cuisine: String = "any cuisine", name: String = "any name", uuid: UUID = UUID(), photoURLLarge: URL, photoURLSmall: URL, sourceURL: URL, youtubeURL: URL) -> (item: RemoteRecipeItem, data: Data) {
        let item = RemoteRecipeItem(cuisine: cuisine, name: name, photoUrlLarge: photoURLLarge, photoUrlSmall: photoURLSmall, sourceUrl: sourceURL, uuid: uuid, youtubeUrl: sourceURL)
        let json = makeFeedDict(cuisine: cuisine, name: name, photoURLLarge: photoURLLarge, photoURLSmall: photoURLSmall, sourceURL: sourceURL, uuid: uuid, youtubeURL: youtubeURL)
        
        return (item, makeItemJSON([json]))
    }
    
    private func makeFeedDict(cuisine: String? = nil, name: String? = "", photoURLLarge: URL? = nil, photoURLSmall: URL? = nil, sourceURL: URL? = nil, uuid: UUID = .init(), youtubeURL: URL? = nil) -> [String: Any] {
        let dict = [
            "cuisine": cuisine,
            "name": name,
            "photoUrlLarge": photoURLLarge?.absoluteString,
            "photoUrlSmall": photoURLSmall?.absoluteString,
            "sourceUrl": sourceURL?.absoluteString,
            "uuid": uuid.uuidString,
            "youtubeUrl": youtubeURL?.absoluteString
        ].compactMapValues { $0 }
        
        return dict
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = ["recipes": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteRecipeLoader, toCompleteWith expectedResult: RemoteRecipeLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                break
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
