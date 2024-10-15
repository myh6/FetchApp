//
//  CoreDataRecipeImageStoreTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/14.
//

import Foundation
import XCTest
import Fetch

extension CoreDataRecipeImageStore {
    func retrieve(dataForURL url: URL, completion: @escaping (RecipeImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataRecipeImageStoreTests: XCTestCase {
    
    func test_retrieveDataForURL_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anyURL())
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
}
