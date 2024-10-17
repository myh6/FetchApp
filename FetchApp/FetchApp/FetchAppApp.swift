//
//  FetchAppApp.swift
//  FetchApp
//
//  Created by Min-Yang Huang on 2024/10/15.
//

import SwiftUI
import Fetch
import CoreData

@main
struct FetchAppApp: App {
    private let recipeLoader: RecipeLoader
    private let imageLoader: RecipeImageDataLoader
    private var store: RecipeImageDataStore = {
        do {
            return try CoreDataRecipeImageStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appending(path: "recipe-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiae a CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    init() {
        let normalURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
        let client = URLSessionHTTPClient(session: .shared)
        self.recipeLoader = RemoteRecipeLoader(client: client, url: normalURL)
        let localImageRecipeLoader = LocalRecipeImageDataLoader(store: store)
        let remoteImageLoader = RemoteRecipeImageDataLoader(client: client)
        let imageLoaderWithFallback = ImageLoaderWithFallbackComposite(primary: localImageRecipeLoader, fallback: remoteImageLoader)
        self.imageLoader = CachingRecipeImageDataLoaderDecorator(decoratee: imageLoaderWithFallback, cache: localImageRecipeLoader)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(recipeLoader: recipeLoader, imageLoader: imageLoader)
        }
    }
}

class NullStore: RecipeImageDataStore {
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
