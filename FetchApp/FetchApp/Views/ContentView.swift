//
//  ContentView.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/15.
//

import SwiftUI
import Fetch

struct ContentView: View {
    @State private var recipes: [RecipeItem] = []
    @State private var isLoading = false
    private let recipeLoader: RecipeLoader
    private let imageLoader: RecipeImageDataLoader
    @State private var hasError: Bool = false
    
    init(recipeLoader: RecipeLoader, imageLoader: RecipeImageDataLoader) {
        self.recipeLoader = recipeLoader
        self.imageLoader = imageLoader
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recipes")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List(recipes) { recipe in
                RecipeDetailView(recipe: recipe, imageLoader: imageLoader)
            }
            .listStyle(.plain)
            .onAppear {
                loadRecipes()
            }
            .refreshable {
                refreshRecipes()
            }
            .overlay{
                if hasError {
                    VStack {
                        Text("Error occured while loading image.")
                        Image(systemName: "exclamationmark.triangle.fill")
                            .padding()
                    }
                } else if recipes.isEmpty && !isLoading {
                    ContentUnavailableView("No recipes.", systemImage: "tray.fill")
                }
            }
        }
    }
    
    private func loadRecipes() {
        isLoading = true
        recipeLoader.load { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let receivedRecipes):
                    recipes = receivedRecipes
                case .failure:
                    hasError = true
                }
                isLoading = false
            }
        }
    }
    
    private func refreshRecipes() {
        loadRecipes()
    }
}

#Preview {
    ContentView(recipeLoader: DummyRecipeLoader(), imageLoader: DummyRecipeImageDataLoader())
}

#Preview("Empty") {
    ContentView(recipeLoader: DummyEmptyRecipeLoader(), imageLoader: DummyRecipeImageDataLoader())
}

#Preview("Error") {
    ContentView(recipeLoader: DummyErrorRecipeLoader(), imageLoader: DummyRecipeImageDataLoader())
}
