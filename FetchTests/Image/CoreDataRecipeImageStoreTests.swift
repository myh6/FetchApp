//
//  CoreDataRecipeImageStoreTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/14.
//

import Foundation
import XCTest
import Fetch
import CoreData

class CoreDataRecipeImageStoreTests: XCTestCase {
    
    func test_retrieveDataForURL_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anyURL())
    }
    
    func test_retrieveDataForURL_deliversEmptyWhenStoredURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let anothreURL = URL(string: "https://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anothreURL)
    }
    
    func test_retrieveDataForURL_deliversStoredDataWhenMatches() {
        let sut = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        insert(data, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(data), for: url)
    }
    
    func test_retrieveDataForURL_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        insert(data, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(data), for: url)
        expect(sut, toCompleteRetrievalWith: .success(data), for: url)
    }
    
    func test_insertDataForURL_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert(anyData(), for: anyURL(), into: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func test_insertDataForURL_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let anotherURL = URL(string: "https://another-url.com")!
        
        insert(anyData(), for: anyURL(), into: sut)
        
        let insertionError = insert(anyData(), for: anotherURL, into: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func test_insertDataForURL_overridesPreviouslyInsertedValue() {
        let sut = makeSUT()
        let url = anyURL()
        let oldData = Data("old data".utf8)
        let newData = Data("new data".utf8)
        
        insert(oldData, for: url, into: sut)
        insert(newData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(newData), for: url)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        var operations = [XCTestExpectation]()
        
        let exp1 = expectation(description: "Operation 1")
        sut.insert(anyData(), for: anyURL()) { _ in
            operations.append(exp1)
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: anyURL()) { _ in
            operations.append(exp2)
            exp2.fulfill()
        }
        
        let exp3 = expectation(description: "Operation 3")
        sut.insert(anyData(), for: anyURL()) { _ in
            operations.append(exp3)
            exp3.fulfill()
        }
        
        wait(for: [exp1, exp2, exp3], timeout: 5.0)
        XCTAssertEqual(operations, [exp1, exp2, exp3])
    }
    
    //MARK: - Helpers
    private func makeSUT() -> CoreDataRecipeImageStore {
        let storeURL = URL(filePath: "/dev/null")
        let sut = try! CoreDataRecipeImageStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: CoreDataRecipeImageStore, toCompleteRetrievalWith expectedResult: RecipeImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected to complete with \(expectedResult), but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func insert(_ data: Data, for url: URL, into sut: CoreDataRecipeImageStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(data, for: url) { result in
            switch result {
            case let .failure(error):
                insertionError = error
                XCTFail("Failed to save \(data) with error \(error)", file: file, line: line)
            case .success:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
}
