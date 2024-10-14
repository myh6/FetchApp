//
//  LocalRecipeImageDataLoader.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation

public class LocalRecipeImageDataLoader: RecipeImageDataLoader {
    private let store: RecipeImageDataStore
    
    public enum LoadError: Swift.Error {
        case notFound, failed
    }
    
    private final class Task: RecipeImageDataLoaderTask {
        private var completion: ((RecipeImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (RecipeImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: RecipeImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public init(store: RecipeImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) })
        }
        return task
    }
}

extension LocalRecipeImageDataLoader {
    public typealias SaveResult = Result<Void, Error>

    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { result in
            completion(.failure(SaveError.failed))
        }
    }
}
