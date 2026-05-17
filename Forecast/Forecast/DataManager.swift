//
//  DataManager.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import Foundation
import CoreLocation
import WeatherKit

class DataManager: NSObject, CLLocationManagerDelegate {

    //MARK: - Properties
    static let sharedInstance = DataManager()
    
    
    //MARK: - Fetch Data Methods
    static func getForecastData(coordinateString: String, completionHandler: @escaping (Weather?, Error?) -> Void) {
        guard let location = location(from: coordinateString) else {
            completionHandler(nil, URLError(.badURL))
            return
        }

        Task {
            do {
                let (current, hourly) = try await WeatherService.shared.weather(
                    for: location,
                    including: .current,
                    .hourly
                )

                let forecast = Weather(weatherKitCurrent: current, hourlyForecast: hourly)
                if let attribution = try? await WeatherService.shared.attribution {
                    forecast.providerName = attribution.serviceName
                    forecast.attributionURL = attribution.legalPageURL
                }

                DispatchQueue.main.async {
                    completionHandler(forecast, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
    }

    private static func location(from coordinateString: String) -> CLLocation? {
        let coordinates = coordinateString.split(separator: ",")
        guard coordinates.count == 2,
              let latitude = Double(coordinates[0]),
              let longitude = Double(coordinates[1]) else {
            return nil
        }

        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
