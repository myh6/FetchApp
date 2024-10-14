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
        
        expect(sut, toCompleteLoadWith: .failure(LocalRecipeImageDataLoader.LoadError.failed)) {
            store.completeRetrieval(with: storeError)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteLoadWith: .failure(LocalRecipeImageDataLoader.LoadError.notFound)) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversImageDataOnSuccess() {
        let imageData = anyData()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteLoadWith: .success(imageData)) {
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
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteInsertionWith: failure(.failed)) {
            store.completeInsertion(with: anyNSError())
        }
    }
    
    func test_saveImageDataForURL_succeedsOnStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteInsertionWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalRecipeImageDataLoader, store: RecipeImageDataStoreSpy) {
        let store = RecipeImageDataStoreSpy()
        let sut = LocalRecipeImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalRecipeImageDataLoader, toCompleteLoadWith expectedResult: RecipeImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
    
    private func failure(_ error: LocalRecipeImageDataLoader.SaveError) -> LocalRecipeImageDataLoader.SaveResult {
        return .failure(error)
    }
    
    private func expect(_ sut: LocalRecipeImageDataLoader, toCompleteInsertionWith expectedResult: LocalRecipeImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case (.failure(let receivedError as LocalRecipeImageDataLoader.SaveError),
                  .failure(let expectedError as LocalRecipeImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
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
        private var retrievalCompletions = [(RetrievalResult) -> Void]()
        private var insertionCompletions = [(InsertionResult) -> Void]()

        func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
            messages.append(.retrieve(dataFor: url))
            retrievalCompletions.append(completion)
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            messages.append(.insert(data: data, for: url))
            insertionCompletions.append(completion)
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](.failure(error))
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](.success(()))
        }
    }
}
