//
//  Category.swift
//  ListOfLists
//
//  Created by Anthony Wong on 2019-06-15.
//  Copyright © 2019 Anthony Wong. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
