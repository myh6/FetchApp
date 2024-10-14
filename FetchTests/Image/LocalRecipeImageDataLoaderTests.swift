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
    
    enum Error: Swift.Error {
        case notFound, failed
    }
    
    init(store: RecipeImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) {
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure:
                completion(.failure(Error.failed))
            case let .success(data):
                guard let data = data, !data.isEmpty else {
                    return completion(.failure(Error.notFound))
                }
                completion(.success(data))
            }
        }
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
        
        sut.loadImageData(from: url) { _ in }
        
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
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterSUTHasBeenDeallocated() {
        let store = RecipeImageDataStore()
        var sut: LocalRecipeImageDataLoader? = LocalRecipeImageDataLoader(store: store)
        
        var capturedResult = [RecipeImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { result in
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
        
        sut.loadImageData(from: anyURL()) { receivedResult in
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
