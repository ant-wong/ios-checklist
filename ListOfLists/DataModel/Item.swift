//
//  Item.swift
//  ListOfLists
//
//  Created by Anthony Wong on 2019-06-15.
//  Copyright © 2019 Anthony Wong. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
