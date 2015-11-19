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
    
    
    //MARK: - Permission Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationCoordinates = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        print("Lat: \(userLocationCoordinates.latitude) Long: \(userLocationCoordinates.longitude)")
        locManager.stopUpdatingLocation()
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "newUserLocationReceived", object: nil))
    }
    
    
    func setUpLocationMonitoring() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
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
    
    func convertCoordinateToString(coordinate: CLLocationCoordinate2D) -> String {
        print("\(coordinate.latitude),\(coordinate.longitude)")
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