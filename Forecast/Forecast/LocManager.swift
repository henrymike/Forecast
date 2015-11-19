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
    
    static let sharedInstance = LocationManager()
    
    var dataManager = DataManager.sharedInstance
    var locManager = CLLocationManager()
    var userLocationCoordinates = CLLocationCoordinate2D()
    var currentLocation = ""
    
    
    //MARK: - Permission Methods
    
    func setUpLocationMonitoring() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("Location authorized")
                locManager.startUpdatingLocation()
            case .Denied, .Restricted:
                print("Location services disabled/restricted")
            case .NotDetermined:
                print("Turn location services on in Settings")
                if (locManager.respondsToSelector("requestWhenInUseAuthorization")) {
                    locManager.requestWhenInUseAuthorization()
                }
                
            }
        } else {
            print("Turn on location services in Settings!")
        }
    }
    
    
    
    //MARK: - Geocoding Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationCoordinates = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        locManager.stopUpdatingLocation()
        
        let location = CLLocation(latitude: userLocationCoordinates.latitude, longitude: userLocationCoordinates.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let currentLoc = placemarks![0]
                print("Current Location: \(currentLoc.locality!)")
                self.currentLocation = String(currentLoc.locality!)
            }
            else {
                print("Problem with the geocoded data")
            }
        })
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "newUserLocationReceived", object: nil))
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
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates = placemark.location!.coordinate
                self.dataManager.getDataFromServer(self.convertCoordinateToString(coordinates))
                
            }
        })
    }
    
}