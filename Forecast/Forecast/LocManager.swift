//
//  LocManager.swift
//  Forecast
//
//  Created by Mike Henry on 11/19/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

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
        
        // Avoid synchronous checks that may block the main thread. Rely on the
        // authorization callback to proceed. If status is not determined, request it.
        let status = locManager.authorizationStatus
        if status == .notDetermined {
            locManager.requestWhenInUseAuthorization()
            return
        }
        
        // For other states, defer to the centralized handler. This will be called
        // immediately here and also from `locationManagerDidChangeAuthorization`.
        handleAuthorizationStatus(status)
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location authorized")
            locManager.requestLocation()
        case .denied, .restricted:
            alertManager.locServicesAlert()
            print("Location services disabled/restricted")
        case .notDetermined:
            print("Turn location services on in Settings")
            locManager.requestWhenInUseAuthorization()
        @unknown default:
            alertManager.locServicesAlert()
            print("Unknown location authorization status")
        }
    }
    
    
    
    //MARK: - Geocoding Methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last?.coordinate.latitude != nil && locations.last?.coordinate.longitude != nil {
            userLocationCoordinates = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        } else {
            print("Last location not found for geocoder")
            return
        }
        
        
        let location = CLLocation(latitude: userLocationCoordinates.latitude, longitude: userLocationCoordinates.longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            print("Unable to create reverse geocoding request")
            return
        }

        request.getMapItems { mapItems, error in
            if let error = error {
                print("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }

            if let currentLoc = mapItems?.first {
                let locationName = currentLoc.addressRepresentations?.cityName ?? currentLoc.name ?? ""
                print("Current Location: \(locationName)")
                self.currentLocation = locationName
                
                DispatchQueue.main.async(execute: { ()
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "newUserLocationReceived"), object: nil))
                })
            } else {
                print("Problem with the user location geocoded data")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func convertCoordinateToString(_ coordinate: CLLocationCoordinate2D) -> String {
        print("Coordinate to String: \(coordinate.latitude),\(coordinate.longitude)")
        reverseGeocodeCoords(coordinate.latitude, long: coordinate.longitude)
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    func geocodeAddress(_ address: String) {
        guard let request = MKGeocodingRequest(addressString: address) else {
            print("Unable to create geocoding request")
            return
        }

        request.getMapItems { mapItems, error in
            if let error = error {
                print("Error: ", error)
                return
            }

            if let mapItem = mapItems?.first {
                let coordinates = mapItem.location.coordinate

                self.userLocationCoordinates = coordinates
                DispatchQueue.main.async(execute: { ()
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "newUserLocationReceived"), object: nil))
                })
            }
        }
    }
    
    func reverseGeocodeCoords(_ lat:Double, long:Double){
        let location = CLLocation(latitude: lat, longitude: long)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            print("Unable to create reverse geocoding request")
            return
        }

        request.getMapItems { mapItems, error in
            if let error = error {
                print("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }

            if let mapItem = mapItems?.first,
               let geocodedLocation = mapItem.addressRepresentations?.cityWithContext ?? mapItem.name {
                self.geocodedLocation = geocodedLocation
                print("Reverse Geocoded Location: \(geocodedLocation)")
                
                DispatchQueue.main.async(execute: { ()
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reverseGeocodedLocationReceived"), object: nil))
                })
            }
        }
    }
}
