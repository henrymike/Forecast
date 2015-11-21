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
    var forecast = Weather()
    
    
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
            newForecast.precipProbability = (tempDict.objectForKey("precipProbability") as! Double)
            newForecast.temperature = (tempDict.objectForKey("temperature") as! Double)
            newForecast.humidity = (tempDict.objectForKey("humidity") as! Double)
            newForecast.windSpeed = (tempDict.objectForKey("windSpeed") as! Double)
            
            forecast = newForecast
            print("Summary:\(newForecast.summary) Icon:\(newForecast.icon) RainChance:\(newForecast.precipProbability) Temp:\(newForecast.temperature) Humidity:\(newForecast.humidity) Wind:\(newForecast.windSpeed)")

        } catch {
            print("JSON Parsing Error")
        }
    }
    
    func getDataFromServer(coordinateString: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        defer {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        let url = NSURL(string: "https://\(baseURLString)/forecast/\(apiKey)/\(coordinateString)")
        print("Search URL:\(url!)")
        let urlRequest = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
            if data != nil {
                print("Got Data")
                self.parseWeatherData(data!)
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "receivedDataFromServer", object: nil))
                }
            } else {
                print("No Data")
            }
        }
        task.resume()
    }
    
}
