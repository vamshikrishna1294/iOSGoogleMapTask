//
//  ViewController.swift
//  iOSMapTask
//
//  Created by Vamsi on 03/12/17.
//  Copyright © 2017 Vamsi. All rights reserved.
//

import UIKit
import GoogleMaps
import  GooglePlaces


class MyPlaceMarker: NSObject {
    
    let title:String
    let locationCordinate:CLLocationCoordinate2D
    let zoom:Float
    
    
      init(title:String, locationCordinate:CLLocationCoordinate2D,zoom:Float) {
        self.title  = title
        self.locationCordinate = locationCordinate
        self.zoom = zoom
    }
}


var currentLocation: CLLocation?
var mapView: GMSMapView!
var placesClient: GMSPlacesClient!
var zoomLevel: Float = 15.0



// A default location to use when location permission is not granted.
let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)

var destinationMarker:MyPlaceMarker?

let destinations = [MyPlaceMarker(title: "Mumbai Airport", locationCordinate: CLLocationCoordinate2DMake(19.0896, 72.8656), zoom: 15),MyPlaceMarker(title: "Chennai Airport", locationCordinate: CLLocationCoordinate2DMake(12.9941, 80.1709), zoom: 15)]

class ViewController: UIViewController {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GoogleMaps - DemoTask "
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.tintColor = UIColor.red
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
 

    }
 }

// Delegates to handle events for the location manager.
extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        let currentlocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                     longitude: location.coordinate.longitude)
        // Creates a marker in the center of the map.
        let marker = GMSMarker(position: currentlocation)
        //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "My Location"
        marker.snippet = "Hello world"
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: UIColor.red)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextMap(_:)))
        
     }
    
    @objc func nextMap(_ sender:UIBarButtonItem)
    {
         if destinationMarker == nil {
            destinationMarker = destinations.first
            mapView.camera = GMSCameraPosition.camera(withTarget: (destinationMarker?.locationCordinate)!, zoom: (destinationMarker?.zoom)!)
            let marker = GMSMarker(position: (destinationMarker?.locationCordinate)!)
            marker.title = destinationMarker?.title
            marker.map = mapView

         }else{
            
            let marker = GMSMarker(position: (destinationMarker?.locationCordinate)!)
            marker.title = destinationMarker?.title
            marker.map = mapView

        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }


}

