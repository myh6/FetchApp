//
//  FeedItemMapper.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/12.
//

import Foundation

enum RecipeItemMapper {
    private struct Root: Decodable {
        let recipes: [RemoteRecipeItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RecipeItem] {
        guard response.statusCode == 200 else { throw RemoteRecipeLoader.Error.invalidData }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.recipes.toModels()
        } catch {
            throw RemoteRecipeLoader.Error.invalidData
        }
    }
}

extension Array where Element == RemoteRecipeItem {
    public func toModels() -> [RecipeItem] {
        return self.map { item in
            RecipeItem(id: item.uuid, name: item.name, cuisine: item.cuisine, photoURL: item.photoUrlLarge)
        }
    }
}
