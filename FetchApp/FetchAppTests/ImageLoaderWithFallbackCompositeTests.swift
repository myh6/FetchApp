//
//  FetchAppTests.swift
//  FetchAppTests
//
//  Created by Min-Yang Huang on 2024/10/15.
//

import XCTest
import Fetch

class ImageLoaderWithFallbackComposite: RecipeImageDataLoader {
    let primary: RecipeImageDataLoader
    let fallback: RecipeImageDataLoader
    
    private struct CompositeTask: RecipeImageDataLoaderTask {
        fileprivate var primary: RecipeImageDataLoaderTask?
        fileprivate var fallback: RecipeImageDataLoaderTask?
        
        func cancel() {
            primary?.cancel()
            fallback?.cancel()
        }
    }
    
    init(primary: RecipeImageDataLoader, fallback: RecipeImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any RecipeImageDataLoaderTask {
        var compositeTask = CompositeTask()
        compositeTask.primary = primary.loadImageData(from: url) { result in
            if case .success(let imageData) = result {
                completion(.success(imageData))
            } else {
                compositeTask.fallback = self.fallback.loadImageData(from: url) { result in }
            }
        }
        
        return compositeTask
    }
}

final class ImageLoaderWithFallbackCompositeTests: XCTestCase {

    func test_loadImageData_deliversPrimaryResultOnPrimarySuccess() {
        let url = URL(string: "https://example.com/primary")!
        let primaryImage = Data("primary data".utf8)
        let fallbackImage = Data("fallback data".utf8)
        let primary = LoaderStub(result: .success(primaryImage))
        let fallback = LoaderStub(result: .success(fallbackImage))
        let sut = ImageLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        
        let exp = expectation(description: "Wait for copletion")
        var receivedImageData: Data?
        
        _ = sut.loadImageData(from: url) { result in
            if case let .success(data) = result {
                receivedImageData = data
            } else {
                XCTFail("Expeced to load with successful primary result, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImageData, primaryImage)
    }
    
    //MARK: - Helpers
    
    private class LoaderStub: RecipeImageDataLoader {
        private let result: RecipeImageDataLoader.Result
        
        private struct Task: RecipeImageDataLoaderTask {
            func cancel() {}
        }
        
        init(result: RecipeImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any RecipeImageDataLoaderTask {
            completion(result)
            return Task()
        }
    }
}
