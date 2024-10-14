//
//  RecipeImageDataLoader.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation

public protocol RecipeImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> RecipeImageDataLoaderTask
}
