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
    var alertManager = AlertManager.sharedInstance
    var baseURLString = "api.forecast.io"
    var apiKey = "33db1afe1d846e9f1b20d8b76be7dbfd"
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
            newForecast.precipProbability = (tempDict.object(forKey: "precipProbability") as! Double)
            newForecast.temperature = (tempDict.object(forKey: "temperature") as! Double)
            newForecast.humidity = (tempDict.object(forKey: "humidity") as! Double)
            newForecast.windSpeed = (tempDict.object(forKey: "windSpeed") as! Double)
            
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
        let url = URL(string: "https://\(baseURLString)/forecast/\(apiKey)/\(coordinateString)")
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
