//
//  RecipeImageDataStore.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import Foundation

public protocol RecipeImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
