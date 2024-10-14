//
//  LocalRecipeImageDataLoaderTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation
import XCTest
import Fetch

class LocalRecipeImageDataLoader {
    let store: RecipeImageDataStore
    
    init(store: RecipeImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) {
        store.retrieve(dataForURL: url) { result in
            if case let .failure(error) = result {
                completion(.failure(error))
            }
        }
    }
}

class RecipeImageDataStore {
    typealias Result = Swift.Result<Data, Error>
    
    private var messages = [(requestedURL: URL, completion: ((Result) -> Void)?)]()
    var receivedMessage: [URL] {
        messages.map(\.requestedURL)
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion?(.failure(error))
    }
}

class LocalRecipeImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessage.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [url])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let storeError = anyNSError()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(storeError)) {
            store.complete(with: storeError)
        }
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalRecipeImageDataLoader, store: RecipeImageDataStore) {
        let store = RecipeImageDataStore()
        let sut = LocalRecipeImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalRecipeImageDataLoader, toCompleteWith expectedResult: RecipeImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Haven't implemented yet")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
