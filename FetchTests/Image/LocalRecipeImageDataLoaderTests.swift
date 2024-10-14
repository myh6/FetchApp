//
//  LocalRecipeImageDataLoaderTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation
import XCTest
import Fetch

class LocalRecipeImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let storeError = anyNSError()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalRecipeImageDataLoader.Error.failed)) {
            store.completeRetrieval(with: storeError)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalRecipeImageDataLoader.Error.notFound)) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversImageDataOnSuccess() {
        let imageData = anyData()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            store.completeRetrieval(with: imageData)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundAfterCancellingTask() {
        let (sut, store) = makeSUT()
        var received = [RecipeImageDataLoader.Result]()
        
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: .none)
        
        XCTAssertTrue(received.isEmpty)
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterSUTHasBeenDeallocated() {
        let store = RecipeImageDataStoreSpy()
        var sut: LocalRecipeImageDataLoader? = LocalRecipeImageDataLoader(store: store)
        
        var capturedResult = [RecipeImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result in
            capturedResult.append(result)
        }
        
        sut = nil
        store.completeRetrieval(with: anyData())
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) {}
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalRecipeImageDataLoader, store: RecipeImageDataStoreSpy) {
        let store = RecipeImageDataStoreSpy()
        let sut = LocalRecipeImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalRecipeImageDataLoader, toCompleteWith expectedResult: RecipeImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receiedData), .success(expectedData)):
                XCTAssertEqual(receiedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expect to complete with \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class RecipeImageDataStoreSpy: RecipeImageDataStore {
        enum Messages: Equatable {
            case insert(data: Data, for: URL)
            case retrieve(dataFor: URL)
        }
        
        var messages = [Messages]()
        private var completions = [(RecipeImageDataStore.Result) -> Void]()
        private var insertionCompletions = [(InsertionResult) -> Void]()

        func retrieve(dataForURL url: URL, completion: @escaping (RecipeImageDataStore.Result) -> Void) {
            messages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            messages.append(.insert(data: data, for: url))
            insertionCompletions.append(completion)
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
