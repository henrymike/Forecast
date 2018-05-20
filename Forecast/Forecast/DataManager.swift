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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var alertManager = AlertManager.sharedInstance
    let baseURLString = "api.darksky.net"
    var apiKey :String?
    var forecast = Weather()
    
    
    //MARK: - Fetch Data Methods
    func parseWeatherData(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let tempDict = (jsonResult as AnyObject).object(forKey: "currently") as! NSDictionary
            print(tempDict)
            let newForecast = Weather()
            newForecast.summary = tempDict.object(forKey: "summary") as! String
            print(newForecast.summary)
            newForecast.icon = tempDict.object(forKey: "icon") as! String
            newForecast.precipProbability = tempDict.object(forKey: "precipProbability") as! Double
            newForecast.temperature = tempDict.object(forKey: "temperature") as! Double
            newForecast.humidity = tempDict.object(forKey: "humidity") as! Double
            newForecast.windSpeed = tempDict.object(forKey: "windSpeed") as! Double
            newForecast.windDirection = tempDict.object(forKey: "windBearing") as! Double
            forecast = newForecast
            print("Summary:\(newForecast.summary) Icon:\(newForecast.icon) RainChance:\(newForecast.precipProbability) Temp:\(newForecast.temperature) Humidity:\(newForecast.humidity) Wind:\(newForecast.windSpeed)")
        } catch {
            alertManager.dataAlert()
            print("JSON Parsing Error")
        }
    }
    
    func getDataFromServer(_ coordinateString: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        defer {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        //Fetch API Key from plist
        var keys :NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            apiKey = dict["darkSkyAPIKey"] as? String
            print("API KEY:\(apiKey)")
        }
        
        //Construct URL and fetch Data
        let url = URL(string: "https://\(baseURLString)/forecast/\(apiKey!)/\(coordinateString)")
        print("Search URL:\(url!)")
        let urlRequest = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if data != nil {
                print("Got Data")
                self.parseWeatherData(data!)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "receivedDataFromServer"), object: nil))
                }
            } else {
                print("No Data")
            }
        }) 
        task.resume()
    }
    
}
