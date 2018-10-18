//
//  ToDoItem.swift
//  Todoey
//
//  Created by Kevin Wang on 10/17/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation

class ToDoItem : Codable {
    
    var activityName : String
    var completed = false
    
    init(activityName : String) {
        self.activityName = activityName
    }
    
}
