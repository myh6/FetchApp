//
//  CachingRecipeImageDataLoader.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import Foundation
import Fetch

public class CachingRecipeImageDataLoaderDecorator: RecipeImageDataLoader {
    private let decoratee: RecipeImageDataLoader
    private let cache: RecipeCache
    
    public init(decoratee: RecipeImageDataLoader, cache: RecipeCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
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
