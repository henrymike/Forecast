//
//  DataManager.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import CoreLocation

let baseURLString = "api.open-meteo.com"

class DataManager: NSObject, CLLocationManagerDelegate {

    //MARK: - Properties
    static let sharedInstance = DataManager()
    var alertManager = AlertManager.sharedInstance
    
    
    //MARK: - Fetch Data Methods
    static func getForecastData(coordinateString: String, completionHandler: @escaping (Weather?, Error?) -> Void) {
        getForecastDataWebRequest(coordinateString: coordinateString, completionHandler: { data, error -> Void in
            guard let forecastData = data else {
                completionHandler(nil, error)
                return
            }
            let decoder = JSONDecoder()
            if let forecastDataResponse = try? decoder.decode(OpenMeteoForecastResponse.self, from: forecastData) {
                DispatchQueue.main.async() {
                    completionHandler(Weather(openMeteoResponse: forecastDataResponse), error)
                }
            } else {
                DispatchQueue.main.async() {
                    completionHandler(nil, error)
                }
            }
        })
    }
    
    private static func getForecastDataWebRequest(coordinateString: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let request = prepareWebRequest(coordinateString: coordinateString) else {
            completionHandler(nil, URLError(.badURL))
            return
        }
        
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
    
    private static func prepareWebRequest(coordinateString: String) -> URLRequest? {
        let coordinates = coordinateString.split(separator: ",")
        guard coordinates.count == 2 else {
            return nil
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURLString
        components.path = "/v1/forecast"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinates[0])),
            URLQueryItem(name: "longitude", value: String(coordinates[1])),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code,wind_speed_10m,wind_direction_10m"),
            URLQueryItem(name: "hourly", value: "precipitation_probability"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_hours", value: "1")
        ]

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
}
