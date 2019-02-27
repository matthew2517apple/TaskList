//
//  Task.swift
//  TaskList
//
//  Created by Matthew Curran on 2/19/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit

class Task: NSObject {
    // the leading s is a 'sigil' indicating the variable is of type 'string':
    var sDescription: String
    var dateCreated: Date
    
    init(description: String, dateCreated: Date = Date()) {
        self.sDescription = description
        self.dateCreated = dateCreated
    }
}
