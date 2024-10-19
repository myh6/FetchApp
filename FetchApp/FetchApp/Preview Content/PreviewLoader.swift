//
//  PreviewLoader.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/18.
//

import Foundation
import Fetch
import UIKit

struct DummyRecipeLoader: RecipeLoader {
    func load(completion: @escaping (RecipeLoader.Result) -> Void) {
        completion(.success([RecipeItem(id: UUID(), name: "Name 1", cuisine: "Cuisine 1", photoURL: URL(string: "https://example.com/photo1.jpg")!)]))
    }
}

struct DummyEmptyRecipeLoader: RecipeLoader {
    func load(completion: @escaping (RecipeLoader.Result) -> Void) {
        completion(.success([]))
    }
}

struct DummyErrorRecipeLoader: RecipeLoader {
    func load(completion: @escaping (RecipeLoader.Result) -> Void) {
        completion(.failure(RemoteRecipeLoader.Error.invalidData))
    }
}

struct DummyRecipeImageDataLoader: RecipeImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any Fetch.RecipeImageDataLoaderTask {
        let data = UIImage(named: "S__179109932")?.pngData()
        if let data {
            completion(.success(data))
        } else {
            completion(.failure(NSError(domain: "error", code: 0)))
        }
        return DummyRecipeImageDataLoaderTask()
    }
}

struct DummyErrorImageDataLoader: RecipeImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any Fetch.RecipeImageDataLoaderTask {
        completion(.failure(RemoteRecipeImageDataLoader.Error.invalidData))
        return DummyRecipeImageDataLoaderTask()
    }
}

struct DummyLoadingRecipeImageDataLoader: RecipeImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any Fetch.RecipeImageDataLoaderTask {
        return DummyRecipeImageDataLoaderTask()
    }
}

struct DummyRecipeImageDataLoaderTask: RecipeImageDataLoaderTask {
    func cancel() {}
}
