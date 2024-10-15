//
//  CoreDataRecipeImageStore.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/14.
//

import CoreData

public class CoreDataRecipeImageStore {
    private static let modelName = "RecipeStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataRecipeImageStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataRecipeImageStore.model else {
            throw StoreError.modelNotFound
        }
        do {
            container = try NSPersistentContainer.load(name: CoreDataRecipeImageStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}

extension CoreDataRecipeImageStore: RecipeImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (RecipeImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                let cache = try RecipeImage.find(url: url, in: context)
                return cache?.data
            })
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (RecipeImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                let cache = try RecipeImage.newInstance(with: url, in: context)
                cache.url = url
                cache.data = data
                try context.save()
            })
        }
    }
}
