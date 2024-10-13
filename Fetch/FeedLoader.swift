//
//  FeedLoader.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/12.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[RemoteFeedItem], Error>
    func load(completion: @escaping (Result) -> Void)
}
