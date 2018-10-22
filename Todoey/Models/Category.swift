//
//  RealmCategory.swift
//  Todoey
//
//  Created by Kevin Wang on 10/21/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    
    @objc dynamic var name : String = ""
    let items = List<ToDoItem>()
    

}
