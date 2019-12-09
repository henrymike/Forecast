//
//  DataManager.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import CoreLocation

let baseURLString = "api.darksky.net"

class DataManager: NSObject, CLLocationManagerDelegate {

    //MARK: - Properties
    static let sharedInstance = DataManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var alertManager = AlertManager.sharedInstance
//    let baseURLString = "api.darksky.net"
    var apiKey: String?
    var forecast = Weather()
    
    
    //MARK: - Fetch Data Methods
    func parseWeatherData(_ data: Data) {
//        do {
//            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//            let tempDict = (jsonResult as AnyObject).object(forKey: "currently") as! NSDictionary
//            print(tempDict)
//            let newForecast = Weather()
//            newForecast.summary = tempDict.object(forKey: "summary") as! String
//            print(newForecast.summary)
//            newForecast.icon = tempDict.object(forKey: "icon") as! String
//            newForecast.precipitation = tempDict.object(forKey: "precipProbability") as! Double
//            newForecast.temperature = tempDict.object(forKey: "temperature") as! Double
//            newForecast.humidity = tempDict.object(forKey: "humidity") as! Double
//            newForecast.windSpeed = tempDict.object(forKey: "windSpeed") as! Double
//            newForecast.windDirection = tempDict.object(forKey: "windBearing") as! Double
//            forecast = newForecast
//            print("Summary:\(newForecast.summary) Icon:\(newForecast.icon) RainChance:\(newForecast.precipitation) Temp:\(newForecast.temperature) Humidity:\(newForecast.humidity) Wind:\(newForecast.windSpeed)")
//        } catch {
//            alertManager.dataAlert()
//            print("JSON Parsing Error")
//        }
    }
    
    func getDataFromServer(_ coordinateString: String) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        defer {
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        }
//        
//        //Fetch API Key from plist
//        var keys :NSDictionary?
//        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
//            keys = NSDictionary(contentsOfFile: path)
//        }
//        if let dict = keys {
//            apiKey = dict["darkSkyAPIKey"] as? String
//            print("API KEY:\(apiKey)")
//        }
//        
//        //Construct URL and fetch Data
//        let url = URL(string: "https://\(baseURLString)/forecast/\(apiKey!)/\(coordinateString)")
//        print("Search URL:\(url!)")
//        let urlRequest = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
//        let urlSession = URLSession.shared
//        let task = urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
//            if data != nil {
//                print("Got Data")
//                self.parseWeatherData(data!)
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "receivedDataFromServer"), object: nil))
//                }
//            } else {
//                print("No Data")
//            }
//        }) 
//        task.resume()
    }
    
    static func getForecastData(coordinateString: String, completionHandler: @escaping (Weather?, Error?) -> Void) {
        getForecastDataWebRequest(coordinateString: coordinateString, completionHandler: { data, error -> Void in
            guard let forecastData = data else {
                completionHandler(nil, error)
                return
            }
            let decoder = JSONDecoder()
            if let forecastDataResponse = try? decoder.decode(WeatherCurrentInfo.self, from: forecastData) {
                DispatchQueue.main.async() {
                    completionHandler(forecastDataResponse.currently, error)
                }
            } else {
                DispatchQueue.main.async() {
                    completionHandler(nil, error)
                }
            }
        })
    }
    
    private static func getForecastDataWebRequest(coordinateString: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        //Fetch API Key from plist
        var keys :NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        var apiKey: String?
        if let dict = keys {
            apiKey = dict["darkSkyAPIKey"] as? String
//            print("API KEY:\(apiKey)")
        }
        
        let request = prepareWebRequest("https://\(baseURLString)/forecast/\(apiKey!)/\(coordinateString)")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 10
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request, completionHandler:  { data, response, error -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let responseData = data {
                        completionHandler(responseData, error)
                    }
                } else {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, error)
            }
        })
        task.resume()
    }
    
    private static func prepareWebRequest(_ url: String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
}
