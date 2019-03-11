//
//  TaskTableViewController.swift
//  TaskList
//
//  Created by Matthew Curran on 2/19/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit
import MapKit

class TaskTableViewController: UITableViewController {
    
    var wishList: PlaceList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addNewLocation(name: String, annotation: MKPointAnnotation) {
        let place = Place(name: name, annotation: annotation)
        let index = self.wishList.add(place)
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @IBAction func showOnMapButton(_ sender: Any) {
        //let coordinate = this.
        //zoomToLocation()
    }
    
    
    func zoomToLocation(place: Place) {
        let coordinate = place.annotation.coordinate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let firstPlace: Place = wishList.placesArray[0]
        //let coordinate = firstPlace.annotation.coordinate
        
        // Switch to a different tab:
        if let tabBarController = appDelegate.mainViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        } else {
            print("Not a tab controller")
        }
        
        // Display location name:
        appDelegate.mapViewController.locationText.text = "\(place.name)"
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 150000, 150000)
        appDelegate.mapViewController.mapView.setRegion(viewRegion, animated: true)
        
    }
    
    // From chapter 11 of Big Nerd Ranch iOS Programming:
    @IBAction func toggleEditingMode(_ sender: UIButton) {
        if isEditing {
            setEditing(false, animated: true)
            // Inform user of available action:
            sender.setTitle("Edit", for: .normal)
        } else {
            setEditing(true, animated: true)
            // Inform user of available action:
            sender.setTitle("Done", for: .normal)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishList.count()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        var place: Place!
        place = wishList.getPlace(at: indexPath.row)
        zoomToLocation(place: place)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var place: Place!
        place = wishList.getPlace(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = place?.name
        
        cell.accessoryType = UITableViewCellAccessoryType.detailButton
        
        if place.hasBeenVisited {
            cell.detailTextLabel?.text = "Visited"
            cell.backgroundColor = UIColor.green
            //place.annotation.tint
        } else {
            cell.detailTextLabel?.text = "Not Visited"
            cell.backgroundColor = UIColor.yellow
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var place: Place!
        place = wishList.getPlace(at: indexPath.row)

        // Toggle the database value (also updates mapView):
        place.toggleVisited()
        // Reload tableView to update (and thus toggle) the tableView display:
        tableView.reloadData()
    }
    
    // Based on the code from chapter 11 of Big Nerd Ranch iOS Programming:
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = wishList.placesArray[indexPath.row]
            
            let alertTitle = "Delete"
            let alertMessage = "Remove \(item.name)?"
            
            let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Remove", style: .destructive, handler: {(action) -> Void in
                self.wishList.remove(item)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                // The next line of code is from:
                // https://stackoverflow.com/questions/32092243/global-variable-in-appdelegate-in-swift/32092335
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                // Also delete the associated pin (annotation) on the MapView:
                appDelegate.mapViewController.mapView.removeAnnotation(item.annotation)
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
}
