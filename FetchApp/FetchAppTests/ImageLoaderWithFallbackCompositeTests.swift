//
//  FetchAppTests.swift
//  FetchAppTests
//
//  Created by Min-Yang Huang on 2024/10/15.
//

import XCTest
import Fetch

class ImageLoaderWithFallbackComposite {
    let primary: RecipeImageDataLoader
    let fallback: RecipeImageDataLoader
    
    init(primary: RecipeImageDataLoader, fallback: RecipeImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
}

final class ImageLoaderWithFallbackCompositeTests: XCTestCase {

    func test_loadImageData_deliversPrimaryResultOnPrimarySuccess() {
        let url = URL(string: "https://example.com/primary")!
        let primary = LoaderStub()
        let fallback = LoaderStub()
        let sut =  (primary: primary, fallback: fallback)
        
        let exp = expectation(description: "Wait for copletion")
        var receivedImageData: Data?
        
        sut.loadImageData(from: url) { result in
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
        func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any RecipeImageDataLoaderTask {
            <#code#>
        }
    }
}
