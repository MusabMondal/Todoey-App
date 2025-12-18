//
//  Item.swift
//  Todoey
//
//  Created by Musab Mondal on 2025-12-16.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date?
    @Persisted var colorHex: String = "#FFFFFF"
    
    @Persisted(originProperty: "items")
    var parentCategory: LinkingObjects<CategoryItem>//Many -> 1 relationship with CategoryItems
    
}
