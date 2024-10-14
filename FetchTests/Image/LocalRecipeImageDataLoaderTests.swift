//
//  LocalRecipeImageDataLoaderTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation
import XCTest
import Fetch

class LocalRecipeImageDataLoader: RecipeImageDataLoader {
    let store: RecipeImageDataStore
    
    enum Error: Swift.Error {
        case notFound, failed
    }
    
    private final class Task: RecipeImageDataLoaderTask {
        private var completion: ((RecipeImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (RecipeImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: RecipeImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    init(store: RecipeImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) })
        }
        return task
    }
}

class RecipeImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    private var messages = [(requestedURL: URL, completion: ((Result) -> Void)?)]()
    var receivedMessage: [URL] {
        messages.map(\.requestedURL)
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void) {
        messages.append((url, completion))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        messages[index].completion?(.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        messages[index].completion?(.success(data))
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
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [url])
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
        let store = RecipeImageDataStore()
        var sut: LocalRecipeImageDataLoader? = LocalRecipeImageDataLoader(store: store)
        
        var capturedResult = [RecipeImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result in
            capturedResult.append(result)
        }
        
        sut = nil
        store.completeRetrieval(with: anyData())
        XCTAssertTrue(capturedResult.isEmpty)
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
}
