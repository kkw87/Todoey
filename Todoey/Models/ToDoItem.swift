//
//  RealmToDoItem.swift
//  Todoey
//
//  Created by Kevin Wang on 10/21/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem : Object {
    @objc dynamic var activityName : String = ""
    @objc dynamic var completed : Bool = false
    @objc dynamic var dateCreated = Date()
    
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
