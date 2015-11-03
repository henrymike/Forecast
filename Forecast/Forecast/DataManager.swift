//
//  DataManager.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import CoreLocation

class DataManager: NSObject, CLLocationManagerDelegate {

    //MARK: - Properties
    static let sharedInstance = DataManager()
    var baseURLString = "api.forecast.io"
    var apiKey = "33db1afe1d846e9f1b20d8b76be7dbfd"
    var forecastArray = [Weather]()
    
    
    //MARK: - Geocoding Methods
    
    func convertCoordinateToString(coordinate: CLLocationCoordinate2D) -> String {
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
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "gotCoordinates", object: nil, userInfo: ["coordinates":self.convertCoordinateToString(coordinates)]))
            }
        })
    }
    
    
    //MARK: - Fetch Data Methods
    func parseWeatherData(data: NSData) {
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
            let tempDict = jsonResult.objectForKey("currently") as! NSDictionary
            print(tempDict)
            let newForecast = Weather()
            newForecast.summary = tempDict.objectForKey("summary") as! String
            print(newForecast.summary)
            newForecast.icon = tempDict.objectForKey("icon") as! String
            newForecast.precipProbability = tempDict.objectForKey("precipProbability") as! NSNumber
            newForecast.temperature = tempDict.objectForKey("temperature") as! NSNumber
            newForecast.humidity = tempDict.objectForKey("humidity") as! NSNumber
            newForecast.windSpeed = tempDict.objectForKey("windSpeed") as! NSNumber
            
            self.forecastArray.append(newForecast)
            print(forecastArray)
            print("Summary:\(newForecast.summary) Icon:\(newForecast.icon) RainChance:\(newForecast.precipProbability) Temp:\(newForecast.temperature) Humidity:\(newForecast.humidity) Wind:\(newForecast.windSpeed)")

        } catch {
            print("JSON Parsing Error")
        }
    }
    
    func getDataFromServer() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true // starts progress spinner
        defer { // whenever you leave this method, it turns off the indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        let url = NSURL(string: "https://\(baseURLString)/forecast/\(apiKey)/37.8267,-122.423")
        let urlRequest = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
            if data != nil {
                print("Got Data")
                self.parseWeatherData(data!)
            } else {
                print("No Data")
            }
        }
        task.resume()
    }
    
}
