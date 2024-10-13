//
//  RemoteRecipeImageDataLoader.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation

public protocol RecipeImageDataLoaderTask {
    func cancel()
}

public protocol RecipeImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> RecipeImageDataLoaderTask
}

public class RemoteRecipeImageDataLoader: RecipeImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    private class HTTPClientTaskWrapper: RecipeImageDataLoaderTask {
        private var completion: ((RecipeImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (RecipeImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func completion(with result: RecipeImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200 && !data.isEmpty {
                    task.completion(with: .success(data))
                } else {
                    task.completion(with: .failure(RemoteRecipeImageDataLoader.Error.invalidData))
                }
            case let .failure(error):
                task.completion(with: .failure(error))
            }
        }
        return task
    }
}
