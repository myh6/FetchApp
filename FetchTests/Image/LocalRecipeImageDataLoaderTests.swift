//
//  LocalRecipeImageDataLoaderTests.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation
import XCTest

class LocalRecipeImageDataLoader {
    let store: RecipeImageDataStore
    
    init(store: RecipeImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL) {
        store.retrieve(dataForURL: url)
    }
}

class RecipeImageDataStore {
    var receivedMessage = [URL]()
    
    func retrieve(dataForURL url: URL) {
        receivedMessage.append(url)
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
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(store.receivedMessage, [url])
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
