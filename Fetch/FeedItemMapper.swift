//
//  FeedItemMapper.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/12.
//

import Foundation

struct FeedItemMapper {
    private init() {}
    private struct Root: Decodable {
        let recipes: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == 200 else { throw RemoteFeedLoader.Error.invalidData }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.recipes
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
}
