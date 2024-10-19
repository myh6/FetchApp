//
//  RecipeView.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/16.
//

import SwiftUI
import Fetch

struct RecipeImageView: View {
    @StateObject private var viewModel: RecipeImageViewModel
    
    init(viewModel: RecipeImageViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if let data = viewModel.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else if viewModel.hasError {
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
                    viewModel.loadImage()
                }
                .onDisappear {
                    viewModel.cancelImageLoading()
                }
            
        }
    }
}
