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
        let exp = expectation(description: "Wait for completion")
        
        sut.loadImageData(from: anyURL()) { result in
            if case let .failure(receivedError) = result {
                XCTAssertEqual(receivedError as NSError, storeError)
            } else {
                XCTFail("Expect .failure, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.complete(with: storeError)
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalRecipeImageDataLoader, store: RecipeImageDataStore) {
        let store = RecipeImageDataStore()
        let sut = LocalRecipeImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
