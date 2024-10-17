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
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
            RecipeImageView(url: recipe.photoURL, imageLoader: imageLoader)
                .frame(maxWidth: .infinity)
                .aspectRatio(contentMode: .fit)
            Text(recipe.cuisine)
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding()
    }
}

#Preview {
    RecipeDetailView(recipe: RecipeItem(id: UUID(), name: "Example name", cuisine: "Example cuisine", photoURL: URL(string: "https://any-url.com")!), imageLoader: DummyRecipeImageDataLoader())
}
