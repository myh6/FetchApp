//
//  RemoteFeedLoader.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/12.
//

import Foundation

public class RemoteRecipeLoader: RecipeLoader {
    public enum Error: Swift.Error {
        case invalidData, connectivity
    }
    
    let client: HTTPClient
    let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RecipeLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(RemoteRecipeLoader.map(data, from: response))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> RecipeLoader.Result {
        do {
            let items = try RecipeItemMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
