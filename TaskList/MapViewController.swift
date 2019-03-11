//
//  MapViewController.swift
//  TaskList
//
//  Created by MJC-iCloud on 3/6/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var activePinName: String = ""
    var activePinAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    @discardableResult func reverseGeocodeComplete(location: CLPlacemark) -> String {
        var locationString = "\(location)"
        
        // If the location has a name, display only the name:
        if let locationName = location.name {
            locationString = "\(locationName)"
        }
        
        print(locationString)
        self.locationText.text = "Add \(locationString)?"
        return locationString
    }
    
    func addPinToMap(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Don't allow the same location to be added twice:
        var repeatedLocation = false
        var sameLat: Bool
        var sameLon: Bool
        
        // Check if this location has already been added:
        // The next line of code is from:
        // https://stackoverflow.com/questions/32092243/global-variable-in-appdelegate-in-swift/32092335
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for eachPlace in appDelegate.wishlistController.wishList.placesArray {
            let otherCoordinate = eachPlace.annotation.coordinate
            // If either lat or lon is different, the location is new:
            sameLat = true
            sameLon = true
            if otherCoordinate.latitude != coordinate.latitude {
                sameLat = false
            }
            if otherCoordinate.longitude != coordinate.longitude {
                sameLon = false
            }
            if sameLat && sameLon {
                repeatedLocation = true
            }
        }
        
        if repeatedLocation {
            userAlertLabel.text = "That location has already been added."
            //locationText.text = ""
        } else {
            annotation.coordinate = coordinate
            
            var name: String = "unknown Location"
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks: [CLPlacemark]?, error: Error?) in
                if error == nil {
                    let placemark = placeMarks![0]
                    name = self.reverseGeocodeComplete(location: placemark)
                    annotation.title = "\(name)"
                    annotation.subtitle = "Not Visited"
                    
                    //self.addPinToWishlist(name: name, annotation: annotation)
                    self.activePinName = name
                    self.activePinAnnotation = annotation
                    
                    self.mapView.addAnnotation(annotation)
                    self.userAlertLabel.text = ""
                    self.addPinButton.setTitle("Add this pin to wishlist", for: .normal)
                    self.addPinButton.isEnabled = true
                } else {
                    print("ERROR in reverseGeocodeLocation; could not add.")
                    self.userAlertLabel.text="Could not add this location; check your internet connection."
                }
            })
        }
    }
    
    func addPinToWishlist(name: String, annotation: MKPointAnnotation) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.wishlistController.addNewLocation(name: name, annotation: annotation)
    }
    
    @IBOutlet weak var addPinButton: UIButton!
    
    @IBAction func addCurrentLocation(_ sender: Any) {
        print("Adding current pin.")
        addPinToWishlist(name: activePinName, annotation: activePinAnnotation)
        addPinButton.setTitle("LONG press to add a new pin", for: .normal)
        addPinButton.isEnabled = false
        locationText.text = "\(activePinName) added"
        
        // Obsolete code to add the user's current location (not current pin's location):
        //if let location = locationManager.location {
        //    addLocation(coordinate: location.coordinate)
        //}
    }
    
    func tryToDeleteActivePin() {
        // Don't delete it if it has been added to the wishlist.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for eachPlace in appDelegate.wishlistController.wishList.placesArray {
            if eachPlace.annotation == activePinAnnotation {
                return;
            }
        }
        
        // If we got this far, the most recently added pin is not in the wishlist,
        // and thus should be deleted:
        mapView.removeAnnotation(activePinAnnotation)
    }
    
    @IBOutlet weak var userAlertLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    @IBOutlet weak var locationText: UILabel!
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("MAP WILL APPEAR")
    }
    
    // Next function from:
    // https://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
    @objc func longTap (gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            print("RECOGNIZED TOUCH")
            // Delete pin from the previously long-touched location (unless it was added to the wishlist):
            tryToDeleteActivePin()
            
            let touchPoint: CGPoint = gestureRecognizer.location(in: mapView)
            let newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            //addAnnotationOnLocation(pointedCoordinate: newCoordinate)
            addPinToMap(coordinate: newCoordinate)
        }
    }
    
    override func viewDidLoad() {
        print("mapView viewDidLoad")
        super.viewDidLoad()
        addPinButton.isEnabled = false
        userAlertLabel.text = ""
        locationText.text = ""
        locationManager.delegate = self
        print("ABOUT TO REQUEST AUTHORIZATION")
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        // Next 2 lines of code from:
        // https://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    func moveToCurrentLocation() {
        if let location = locationManager.location {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            
            moveToCurrentLocation()
        } else {
            let alert = UIAlertController(title: "Can't display location", message: "Please grant permission in settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: { (action: UIAlertAction) -> Void in UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!) } ))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // The following function could theoretically slow down with enough pins added.
    // In that case, this code could be useful:
    // https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotation = MKPinAnnotationView()
            if let subtitle = annotation.subtitle {
                print("Subtitle: \(subtitle!) ")
                print("Prefix: \(subtitle!.prefix(3))")
                if subtitle!.prefix(3) == "Not" {
                    pinAnnotation.pinTintColor = UIColor.yellow
                } else {
                    pinAnnotation.pinTintColor = UIColor.green
                }

            }
            pinAnnotation.annotation = annotation
            pinAnnotation.canShowCallout = true
            return pinAnnotation
        } else {
            return nil
        }
    }
    
}


