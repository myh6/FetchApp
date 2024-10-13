//
//  FeedItem.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/11.
//

import Foundation

public struct RemoteRecipeItem: Codable {
    public let cuisine: String
    public let name: String
    public let photoUrlLarge: URL
    public let photoUrlSmall: URL
    public let sourceUrl: URL?
    public let uuid: UUID
    public let youtubeUrl: URL?
    
    public init(
        cuisine: String,
        name: String,
        photoUrlLarge: URL,
        photoUrlSmall: URL,
        sourceUrl: URL,
        uuid: UUID,
        youtubeUrl: URL
    ) {
        self.cuisine = cuisine
        self.name = name
        self.photoUrlSmall = photoUrlSmall
        self.photoUrlLarge = photoUrlLarge
        self.sourceUrl = sourceUrl
        self.uuid = uuid
        self.youtubeUrl = youtubeUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case cuisine, name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case uuid
        case youtubeUrl = "youtube_url"
    }
}
