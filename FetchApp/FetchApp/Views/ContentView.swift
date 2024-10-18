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
                if recipes.isEmpty && !isLoading {
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
                case .failure(let error):
                    hasError = true
                    // error.localizedDescription
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

struct DummyRecipeLoader: RecipeLoader {
    func load(completion: @escaping (RecipeLoader.Result) -> Void) {
        completion(.success([RecipeItem(id: UUID(), name: "Name 1", cuisine: "Cuisine 1", photoURL: URL(string: "https://example.com/photo1.jpg")!)]))
    }
}

struct DummyEmptyRecipeLoader: RecipeLoader {
    func load(completion: @escaping (RecipeLoader.Result) -> Void) {
        completion(.success([]))
    }
}
