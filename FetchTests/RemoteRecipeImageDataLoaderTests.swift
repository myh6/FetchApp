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
    let client: Any
    
    init(client: Any) {
        self.client = client
    }
}

final class RemoteRecipeImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRecipeImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        var requestedURLs = [URL]()
        
        func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
            requestedURLs.append(url)
        }
    }
}
