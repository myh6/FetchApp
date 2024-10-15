//
//  RecipeCache.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/14.
//

import Foundation

public protocol RecipeCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
