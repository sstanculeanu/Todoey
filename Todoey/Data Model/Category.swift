//
//  Category.swift
//  Todoey
//
//  Created by Sorin Stanculeanu on 06/01/2018.
//  Copyright © 2018 Sorin Stanculeanu. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name : String = ""
    let items = List<Item>() //each category has a list of items -> forward relation
    @objc dynamic var color : String = ""
}
