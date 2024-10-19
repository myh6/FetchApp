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
    private let recipeImageFactory: (URL) -> RecipeImageView
    
    init(recipe: RecipeItem, recipeImageFactory: @escaping (URL) -> RecipeImageView) {
        self.recipe = recipe
        self.recipeImageFactory = recipeImageFactory
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
            recipeImageFactory(recipe.photoURL)
                .frame(maxWidth: .infinity)
                .aspectRatio(contentMode: .fit)
            Text(recipe.cuisine)
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding()
    }
}
