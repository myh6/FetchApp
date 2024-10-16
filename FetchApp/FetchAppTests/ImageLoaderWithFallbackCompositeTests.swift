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
        let primaryImage = Data("primary data".utf8)
        let fallbackImage = Data("fallback data".utf8)
        let sut = makeSUT(primaryResult: .success(primaryImage), fallbackResult: .success(fallbackImage))
        
        expect(sut, toCompleteWith: .success(primaryImage))
    }
    
    //MARK: - Helpers
    private func makeSUT(primaryResult: RecipeImageDataLoader.Result, fallbackResult: RecipeImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> ImageLoaderWithFallbackComposite {
        let primary = LoaderStub(result: primaryResult)
        let fallback = LoaderStub(result: fallbackResult)
        let sut = ImageLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: ImageLoaderWithFallbackComposite, toCompleteWith expectedResult: RecipeImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: URL(string: "https://any-url.com")!) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected to complete with \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
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

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leaks", file: file, line: line)
        }
    }
}
