//
//  Task.swift
//  TaskList
//
//  Created by Matthew Curran on 2/19/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit
import MapKit

class Task: NSObject {
    var name: String
    var dateCreated: Date
    var annotation: MKPointAnnotation
    
    init(name: String, annotation: MKPointAnnotation, dateCreated: Date = Date()) {
        self.name = name
        self.dateCreated = dateCreated
        self.annotation = annotation
    }
}
