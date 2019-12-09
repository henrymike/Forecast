//
//  Weather.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class Weather: NSObject, Codable {
    var summary: String?
    var icon: String?
    var precipitation: Double?
    var temperature: Double?
    var humidity: Double?
    var windSpeed: Double?
    var windDirection: Double?
    
    enum CodingKeys: String, CodingKey {
        case summary
        case icon
        case precipitation = "precipProbability"
        case temperature
        case humidity
        case windSpeed
        case windDirection = "windBearing"
    }
}

class WeatherCurrentInfo: NSObject, Codable {
    var currently: Weather?
}
