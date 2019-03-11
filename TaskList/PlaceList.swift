//
//  TaskList.swift
//  TaskList
//
//  Created by Matthew Curran on 2/19/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit

class PlaceList {
    var placesArray = [Place]()
    
    func add(_ place: Place) -> Int {
        placesArray.append(place)
        return placesArray.endIndex-1
    }
    
    func getPlace(at index: Int) -> Place? {
        if placesArray.indices.contains(index) {
            return placesArray[index]
        }
        return nil
    }
    
    func count() -> Int {
        return placesArray.count
    }
    
    func remove(_ place: Place) {
        if let index = placesArray.index(of: place) {
            placesArray.remove(at: index)
        }
    }
    
    /*  Not tested:
    func toggleVisited(at index: Int) {
        var place: Place!
        place = placesArray[index]
        place.toggleVisited()
    }
    */
}
