//
//  RecipeImageViewModel.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/18.
//

import Foundation
import Fetch

class RecipeImageViewModel: ObservableObject {
    @Published var imageData: Data?
    @Published var hasError: Bool = false
    
    private var imageLoadingTask: RecipeImageDataLoaderTask? = nil
    private let imageLoader: RecipeImageDataLoader
    private let url: URL
    
    init(imageLoader: RecipeImageDataLoader, url: URL) {
        self.imageLoader = imageLoader
        self.url = url
    }
    
    func loadImage() {
        imageLoadingTask = imageLoader.loadImageData(from: url) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.imageData = data
                case .failure:
                    self.imageData = nil
                    self.hasError = true
                }
            }
        }
    }
    
    func cancelImageLoading() {
        imageLoadingTask?.cancel()
    }
}
