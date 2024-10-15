//
//  RecipeImage.swift
//  Fetch
//
//  Created by Min-Yang Huang on 2024/10/14.
//

import CoreData

@objc(RecipeImage)
class RecipeImage: NSManagedObject {
    @NSManaged var data: Data
    @NSManaged var url: URL
}

extension RecipeImage {
    static func newInstance(with url: URL, in context: NSManagedObjectContext) throws -> RecipeImage {
        try find(url: url, in: context).map(context.delete)
        return RecipeImage(context: context)
    }
    
    static func find(url: URL, in context: NSManagedObjectContext) throws -> RecipeImage? {
        let request = NSFetchRequest<RecipeImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(RecipeImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

