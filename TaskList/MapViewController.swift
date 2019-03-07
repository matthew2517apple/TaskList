//
//  MapViewController.swift
//  TaskList
//
//  Created by MJC-iCloud on 3/6/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    func reverseGeocodeComplete(location: CLPlacemark) {
        var locationString = "\(location)"
        
        // If the location has a name, display only the name:
        if let locationName = location.name {
            locationString = "\(locationName)"
        }
        
        print(locationString)
        self.locationText.text =  locationString
    }
    
    @IBAction func addCurrentLocationMarker(_ sender: Any) {
        userAlertLabel.text = "CLICKED FROM OBSOLETE"
    }
    
    @IBAction func addCurrentLocation(sender: AnyObject) {
        userAlertLabel.text = "CLICKED"
        print("GOT THIS FAR")
        
        if let location = locationManager.location {
            let annotation = MKPointAnnotation()
            
            // Shorter distances are very hard to test in the debugger:
            let minDistanceAllowed = 500000.0
            var minDistance = minDistanceAllowed + 999999.0
            var tooClose = false
            let listOfAnnotations = mapView.annotations
            
            for eachAnnotation in listOfAnnotations {
                let otherLocation2D = eachAnnotation.coordinate
                let otherLocation = CLLocation(latitude: otherLocation2D.latitude, longitude: otherLocation2D.longitude)
                
                let distance = location.distance(from: otherLocation)
                if distance > 0 && distance < minDistance {
                    minDistance = distance
                }
                //annotation.title = "distance: \(minDistance)" //unit test
            }
            
            if minDistance <  minDistanceAllowed {
                tooClose = true
            }
            if tooClose {
                let distanceText = String(format: "%.f", minDistance)
                userAlertLabel.text = "Could not add pin; you were within \(distanceText) of another pin.  Minimum allowed distance is 500k."
                locationText.text = ""
            } else {
                annotation.coordinate = location.coordinate
                let timeStamp = dateFormatter.string(from: Date())
                annotation.title = "You were here at \(timeStamp)"
                mapView.addAnnotation(annotation)
                userAlertLabel.text = ""
                
                geocoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks: [CLPlacemark]?, error: Error?) in
                    if error == nil {
                        let placemark = placeMarks![0]
                        self.reverseGeocodeComplete(location: placemark)
                    }
                })
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        print("ABOUT TO REQUEST AUTHORIZATION")
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotation = MKPinAnnotationView()
            pinAnnotation.pinTintColor = UIColor.red
            pinAnnotation.annotation = annotation
            pinAnnotation.canShowCallout = true
            return pinAnnotation
        } else {
            return nil
        }
    }
    
}


