//
//  CategoryItem.swift
//  Todoey
//
//  Created by Musab Mondal on 2025-12-16.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift


class CategoryItem: Object{
    @Persisted var name : String = ""
    @Persisted var colorHex: String = "#FFFFFF"
    @Persisted var items = List<Item>()   //1 -> Many relationship with Item
}
