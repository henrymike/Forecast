//
//  LocManager.swift
//  Forecast
//
//  Created by Mike Henry on 11/19/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //MARK: - Properties
    static let sharedInstance = LocationManager()
    var dataManager = DataManager.sharedInstance
    var locManager = CLLocationManager()
    var alertManager = AlertManager.sharedInstance
    var userLocationCoordinates = CLLocationCoordinate2D()
    var currentLocation = ""
    var geocodedLocation = ""
    
    
    //MARK: - Permission Methods
    
    func setUpLocationMonitoring() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyKilometer
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("Location authorized")
                locManager.requestLocation()
            case .Denied, .Restricted:
                //TODO: Add error message that Location services are disabled; please turn them back on
                alertManager.locServicesAlert()
                print("Location services disabled/restricted")
            case .NotDetermined:
                //TODO: Add error message that Location services are disabled; please turn them back on
                alertManager.locServicesAlert()
                print("Turn location services on in Settings")
                if (locManager.respondsToSelector("requestWhenInUseAuthorization")) {
                    locManager.requestWhenInUseAuthorization()
                }
            }
        } else {
            //TODO: Add error message that Location services are disabled; please turn them back on
            alertManager.locServicesAlert()
            print("Turn on location services in Settings!")
        }
    }
    
    
    
    //MARK: - Geocoding Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationCoordinates = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        
        let location = CLLocation(latitude: userLocationCoordinates.latitude, longitude: userLocationCoordinates.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                //TODO: Add error message with localizedDescription text for user
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let currentLoc = placemarks![0]
                print("Current Location: \(currentLoc.locality!)")
                self.currentLocation = String(currentLoc.locality!)
                
                dispatch_async(dispatch_get_main_queue(), { ()
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "newUserLocationReceived", object: nil))
                })
            }
            else {
                //TODO: Add error message for user about data issue
                print("Problem with the geocoded data")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //TODO: Add error message with error text for user
        print("Error: \(error)")
    }
    
    func convertCoordinateToString(coordinate: CLLocationCoordinate2D) -> String {
        print("Coordinate to String: \(coordinate.latitude),\(coordinate.longitude)")
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    
    func geocodeAddress(address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {
            (placemarks, error) -> Void in
            if((error) != nil){
                //TODO: Add error message instructing user to try search again
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates = placemark.location!.coordinate
                self.dataManager.getDataFromServer(self.convertCoordinateToString(coordinates))
                
            }
        })
    }
    
}