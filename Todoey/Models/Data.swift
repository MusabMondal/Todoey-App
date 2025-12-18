//
//  Data.swift
//  Todoey
//
//  Created by Musab Mondal on 2025-12-16.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    @Persisted var name: String = ""
    @Persisted var age: Int = 0
}
