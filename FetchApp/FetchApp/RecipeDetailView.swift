//
//  RecipeDetailView.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import SwiftUI
import Fetch

struct RecipeDetailView: View {
    let recipe: RecipeItem
    private let imageLoader: RecipeImageDataLoader
    
    init(recipe: RecipeItem, imageLoader: RecipeImageDataLoader) {
        self.recipe = recipe
        self.imageLoader = imageLoader
    }
    
    var body: some View {
        VStack {
            Text(recipe.name)
            RecipeImageView(url: recipe.photoURL, imageLoader: imageLoader)
            Text(recipe.cuisine)
        }
    }
}

#Preview {
    RecipeDetailView(recipe: RecipeItem(id: UUID(), name: "Example name", cuisine: "Example cuisine", photoURL: URL(string: "https://any-url.com")!), imageLoader: DummyRecipeImageDataLoader())
}
