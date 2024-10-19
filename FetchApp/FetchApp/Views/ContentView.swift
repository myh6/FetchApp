//
//  ContentView.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/15.
//

import SwiftUI
import Fetch

struct ContentView: View {
    @StateObject private var viewModel: RecipeListViewModel
    private let recipeDetailViewFactory: (RecipeItem) -> RecipeDetailView
    
    init(recipeLoader: RecipeLoader, recipeDetailViewFactory: @escaping (RecipeItem) -> RecipeDetailView) {
        self._viewModel = StateObject(wrappedValue: RecipeListViewModel(recipeLoader: recipeLoader))
        self.recipeDetailViewFactory = recipeDetailViewFactory
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recipes")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List(viewModel.recipes) { recipe in
                recipeDetailViewFactory(recipe)
            }
            .listStyle(.plain)
            .onAppear {
                viewModel.loadRecipes()
            }
            .refreshable {
                viewModel.refresh()
            }
            .overlay{
                if viewModel.hasError {
                    VStack {
                        Text("Error occured while loading image.")
                        Image(systemName: "exclamationmark.triangle.fill")
                            .padding()
                    }
                } else if viewModel.recipes.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView("No recipes.", systemImage: "tray.fill")
                }
            }
        }
    }
}
