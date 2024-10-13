//
//  FeedItemMapper.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/12.
//

import Foundation

struct RecipeItemMapper {
    private init() {}
    private struct Root: Decodable {
        let recipes: [RemoteRecipeItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteRecipeItem] {
        guard response.statusCode == 200 else { throw RemoteRecipeLoader.Error.invalidData }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.recipes
        } catch {
            throw RemoteRecipeLoader.Error.invalidData
        }
    }
}
