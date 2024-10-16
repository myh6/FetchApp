//
//  FetchAppTests.swift
//  FetchAppTests
//
//  Created by Min-Yang Huang on 2024/10/15.
//

import XCTest
import Fetch
import FetchApp

final class ImageLoaderWithFallbackCompositeTests: XCTestCase {

    func test_loadImageData_deliversPrimaryResultOnPrimarySuccess() {
        let primaryImage = Data("primary data".utf8)
        let fallbackImage = Data("fallback data".utf8)
        let (sut, _, _) = makeSUT(primaryResult: .success(primaryImage), fallbackResult: .success(fallbackImage))
        
        expect(sut, toCompleteWith: .success(primaryImage))
    }
    
    func test_loadImageData_delviersFallbackResultOnPrimaryFailure() {
        let fallbackImage = Data("fallback data".utf8)
        let (sut, _, _) = makeSUT(
            primaryResult: .failure(LocalRecipeImageDataLoader.LoadError.failed),
            fallbackResult: .success(fallbackImage))
        
        expect(sut, toCompleteWith: .success(fallbackImage))
    }
    
    func test_loadImageData_deliversErrorOnFallbackFailure() {
        let (sut, _, _) = makeSUT(primaryResult: .failure(LocalRecipeImageDataLoader.LoadError.failed), fallbackResult: .failure(RemoteRecipeImageDataLoader.Error.connectivity))
        
        expect(sut, toCompleteWith: .failure(RemoteRecipeImageDataLoader.Error.connectivity))
    }
    
    func test_cancel_cancelsBothPrimaryAndFallbackTasks() {
        let (sut, primaryTask, fallbackTask) = makeSUT(primaryResult: .failure(NSError(domain: "any error", code: 0)), fallbackResult: .success(Data()))
        
        let task = sut.loadImageData(from: URL(string: "https://any-url.com")!) { _ in }
        
        task.cancel()
        XCTAssertTrue(primaryTask.isCancelled)
        XCTAssertTrue(fallbackTask.isCancelled)
    }
    
    //MARK: - Helpers
    private func makeSUT(primaryResult: RecipeImageDataLoader.Result, fallbackResult: RecipeImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> (sut: ImageLoaderWithFallbackComposite, primaryTask: LoaderStub.TaskSpy, fallbackTask: LoaderStub.TaskSpy) {
        let primaryTask = LoaderStub.TaskSpy()
        let fallbackTask = LoaderStub.TaskSpy()
        let primary = LoaderStub(result: primaryResult, task: primaryTask)
        let fallback = LoaderStub(result: fallbackResult, task: fallbackTask)
        let sut = ImageLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(primaryTask, file: file, line: line)
        trackForMemoryLeaks(fallbackTask, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryTask, fallbackTask)
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
        private let task: TaskSpy
        
        class TaskSpy: RecipeImageDataLoaderTask {
            var isCancelled: Bool = false
            func cancel() {
                isCancelled = true
            }
        }
        
        init(result: RecipeImageDataLoader.Result, task: TaskSpy) {
            self.result = result
            self.task = task
        }
        
        func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any RecipeImageDataLoaderTask {
            completion(result)
            return task
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
