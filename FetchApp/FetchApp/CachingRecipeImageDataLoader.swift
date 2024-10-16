//
//  CachingRecipeImageDataLoader.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import Foundation
import Fetch

public class CachingRecipeImageDataLoader: RecipeImageDataLoader {
    private let loader: RecipeImageDataLoader
    private let cache: RecipeCache
    
    public init(loader: RecipeImageDataLoader, cache: RecipeCache) {
        self.loader = loader
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        return loader.loadImageData(from: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                cache.save(data, for: url) { _ in }
                completion(.success(data))
            default:
                break
            }
        }
    }
}
