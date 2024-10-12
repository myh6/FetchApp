//
//  FetchTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/11.
//
 
import XCTest
import Fetch

protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>
    func load(completion: @escaping (Result) -> Void)
}

class RemoteFeedLoader: FeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url)
    }
}

class HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leaks", file: file, line: line)
        }
    }
}
