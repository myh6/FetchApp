//
//  CachingRecipeImageDataLoaderTests.swift
//  FetchAppTests
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import XCTest
import Fetch

class CachingRecipeImageDataLoader: RecipeImageDataLoader {
    private let loader: RecipeImageDataLoader
    private let cache: RecipeCache
    
    init(loader: RecipeImageDataLoader, cache: RecipeCache) {
        self.loader = loader
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        return loader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.cache.save(data, for: url) { _ in }
                completion(.success(data))
            default:
                break
            }
        }
    }
}

final class CachingRecipeImageDataLoaderTests: XCTestCase {
    func test_loadImageData_cachesDataOnLoaderSuccess() {
        let url = URL(string: "https://any-url.com")!
        let image = Data("image data".utf8)
        let (sut, _, cache) = makeSUT(loaderResult: .success(image))
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(cache.messages, [.save(data: image, for: url)])
    }
    
    //MARK: - Helpers
    private func makeSUT(loaderResult: RecipeImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> (CachingRecipeImageDataLoader, LoaderSpy, CacheSpy) {
        let loader = LoaderSpy(result: loaderResult)
        let cache = CacheSpy()
        let sut = CachingRecipeImageDataLoader(loader: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader, cache)
    }
    
    private class LoaderSpy: RecipeImageDataLoader {
        private let result: RecipeImageDataLoader.Result
        
        init(result: RecipeImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
            completion(result)
            return Task()
        }
        
        private class Task: RecipeImageDataLoaderTask {
            func cancel() {}
        }
    }
    
    private class CacheSpy: RecipeCache {
        enum Message: Equatable {
            case save(data: Data, for: URL)
        }
        
        private(set) var messages = [Message]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (RecipeCache.Result) -> Void) {
            messages.append(.save(data: data, for: url))
            completion(.success(()))
        }
    }
}
