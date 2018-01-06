//
//  Item.swift
//  Todoey
//
//  Created by Sorin Stanculeanu on 06/01/2018.
//  Copyright © 2018 Sorin Stanculeanu. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") //each item has a parentCategory -> backward relation
}
