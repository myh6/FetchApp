//
//  RecipeItem.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import Foundation

public struct RecipeItem: Identifiable {
    public let id: UUID
    public let name: String
    public let cuisine: String
    public let photoURL: URL
    
    public init(id: UUID, name: String, cuisine: String, photoURL: URL) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.photoURL = photoURL
    }
}
