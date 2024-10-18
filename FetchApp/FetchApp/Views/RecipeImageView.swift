//
//  RecipeView.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import SwiftUI
import Fetch

struct RecipeImageView: View {
    let url: URL
    private let imageLoader: RecipeImageDataLoader
    @State private var imageData: Data?
    @State private var imageLoadingTask: RecipeImageDataLoaderTask? = nil
    @State private var hasError: Bool = false
    
    init(url: URL, imageLoader: RecipeImageDataLoader) {
        self.url = url
        self.imageLoader = imageLoader
    }
    
    var body: some View {
        if let data = imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else if hasError {
            Rectangle()
                .fill(Color.red)
                .overlay {
                    VStack {
                        Text("Error occured while loading image.")
                        Image(systemName: "exclamationmark.triangle.fill")
                            .padding()
                    }
                }
        } else {
            ShimmeringView()
                .onAppear {
                    startLoadingImage()
                }
                .onDisappear {
                    cancelImageLoading()
                }
            
        }
    }
    
    private func startLoadingImage() {
        imageLoadingTask = imageLoader.loadImageData(from: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    imageData = data
                case .failure(let error):
                    imageData = nil
                    hasError = true
                    // error.localizedDescription
                }
            }
        }
    }
    
    private func cancelImageLoading() {
        imageLoadingTask?.cancel()
    }
}

#Preview("With image") {
    RecipeImageView(url: URL(string: "https://any-url.com")!, imageLoader: DummyRecipeImageDataLoader())
}

#Preview("With error") {
    RecipeImageView(url: URL(string: "https://any-url.com")!, imageLoader: DummyErrorImageDataLoader())
}

#Preview("Loading") {
    RecipeImageView(url: URL(string: "https://any-url.com")!, imageLoader: DummyLoadingRecipeImageDataLoader())
}
