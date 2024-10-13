//
//  FeedLoader.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/12.
//

import Foundation

public protocol RecipeLoader {
    typealias Result = Swift.Result<[RemoteRecipeItem], Error>
    func load(completion: @escaping (Result) -> Void)
}
