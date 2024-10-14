//
//  FetchEndToEndTests.swift
//  FetchEndToEndTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import XCTest
import Fetch

final class FetchEndToEndTests: XCTestCase {
    
    func test() {
        let result = getRecipeResult()
        switch result {
        case let .success(items):
            XCTAssertEqual(items.count, 65)
            let first = items.first!
            XCTAssertEqual(first.cuisine, "Malaysian")
            XCTAssertEqual(first.name, "Apam Balik")
            XCTAssertEqual(first.photoUrlLarge.absoluteString, "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")
            XCTAssertEqual(first.photoUrlSmall.absoluteString, "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")
            XCTAssertEqual(first.sourceUrl?.absoluteString, "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ")
            XCTAssertEqual(first.uuid.uuidString.lowercased(), "0c6ca6e7-e32a-4053-b824-1dbf749910d8")
            XCTAssertEqual(first.youtubeUrl?.absoluteString, "https://www.youtube.com/watch?v=6R8ffRRJcrg")
        default:
            XCTFail("Expected successful result, got \(String(describing: result)) instead.")
        }
    }
    
    private func getRecipeResult(file: StaticString = #file, line: UInt = #line) -> RecipeLoader.Result? {
        let serverURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
        let client = URLSessionHTTPClient(session: .shared)
        let loader = RemoteRecipeLoader(client: client, url: serverURL)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: RecipeLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }

}
