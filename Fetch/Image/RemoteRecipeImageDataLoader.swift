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

public class RemoteRecipeImageDataLoader: RecipeImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData, connectivity
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
        
        func complete(with result: RecipeImageDataLoader.Result) {
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
    
    public func loadImageData(from url: URL, completion: @escaping (RecipeImageDataLoader.Result) -> Void) -> RecipeImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValid = response.statusCode == 200 && !data.isEmpty
                    return isValid ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
    }
}
