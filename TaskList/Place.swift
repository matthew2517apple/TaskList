//
//  Task.swift
//  TaskList
//
//  Created by Matthew Curran on 2/19/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit
import MapKit

class Place: NSObject {
    var name: String
    var annotation: MKPointAnnotation
    var hasBeenVisited: Bool
    var dateCreated: Date
    
    init(name: String, annotation: MKPointAnnotation, dateCreated: Date = Date()) {
        self.name = name
        self.annotation = annotation
        self.annotation.subtitle = "Not Visited"    // default to not visited.
        self.dateCreated = dateCreated
        self.hasBeenVisited = false
    }
    
    func toggleVisited() {
        if self.hasBeenVisited {
            self.hasBeenVisited = false
            self.annotation.subtitle = "Not Visited"
        } else {
            self.hasBeenVisited = true
            self.annotation.subtitle = "Visited"
        }
        
        // The next line of code is from:
        // https://stackoverflow.com/questions/32092243/global-variable-in-appdelegate-in-swift/32092335
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Update the UI display in mapView:
        appDelegate.mapViewController.mapView.removeAnnotation(annotation)
        appDelegate.mapViewController.mapView.addAnnotation(annotation)
    }
}
