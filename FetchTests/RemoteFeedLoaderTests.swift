//
//  FetchTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/11.
//
 
import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteFeedLoader(client: client)
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
