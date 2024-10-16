//
//  ImageLoaderWithFallbackComposite.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import Foundation
import Fetch

public class ImageLoaderWithFallbackComposite: RecipeImageDataLoader {
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
    
    public init(primary: RecipeImageDataLoader, fallback: RecipeImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> any RecipeImageDataLoaderTask {
        var compositeTask = CompositeTask()
        compositeTask.primary = primary.loadImageData(from: url) { [weak self] result in
            guard let self else { return }
            if case .success(let imageData) = result {
                completion(.success(imageData))
            } else {
                compositeTask.fallback = fallback.loadImageData(from: url) { completion($0) }
            }
        }
        return compositeTask
    }
}
