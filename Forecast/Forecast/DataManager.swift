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
    
    
    //MARK: - Fetch Data Methods
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
