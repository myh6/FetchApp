//
//  RecipeListViewModel.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/18.
//

import Foundation
import Fetch

class RecipeListViewModel: ObservableObject {
    @Published var recipes: [RecipeItem] = []
    @Published var isLoading = false
    @Published var hasError = false
    
    private let recipeLoader: RecipeLoader
    
    init(recipeLoader: RecipeLoader) {
        self.recipeLoader = recipeLoader
    }
    
    func loadRecipes() {
        isLoading = true
        recipeLoader.load { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let receivedRecipes):
                    self.recipes = receivedRecipes
                case .failure:
                    self.hasError = true
                }
                self.isLoading = false
            }
        }
    }
    
    func refresh() {
        loadRecipes()
    }
}
