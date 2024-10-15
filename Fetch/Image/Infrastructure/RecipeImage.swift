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

