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

    override init() {
        super.init()
    }

    init(openMeteoResponse: OpenMeteoForecastResponse) {
        let current = openMeteoResponse.current

        self.summary = Self.summary(forWeatherCode: current.weatherCode)
        self.icon = Self.iconName(forWeatherCode: current.weatherCode)
        self.precipitation = Double(openMeteoResponse.hourly.precipitationProbability.first ?? 0) / 100
        self.temperature = current.temperature
        self.windSpeed = current.windSpeed
        self.windDirection = current.windDirection
    }

    private static func summary(forWeatherCode weatherCode: Int) -> String {
        switch weatherCode {
        case 0:
            return "Clear"
        case 1, 2:
            return "Partly Cloudy"
        case 3:
            return "Cloudy"
        case 45, 48:
            return "Fog"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            return "Rain"
        case 71, 73, 75, 77, 85, 86:
            return "Snow"
        case 95, 96, 99:
            return "Wind"
        default:
            return "Clear"
        }
    }

    private static func iconName(forWeatherCode weatherCode: Int) -> String {
        switch weatherCode {
        case 0:
            return "clear-day"
        case 1, 2:
            return "partly-cloudy-day"
        case 3:
            return "cloudy"
        case 45, 48:
            return "fog"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            return "rain"
        case 71, 73, 75, 77, 85, 86:
            return "snow"
        case 95, 96, 99:
            return "wind"
        default:
            return "clear-day"
        }
    }
}

struct OpenMeteoForecastResponse: Codable {
    let current: OpenMeteoCurrentWeather
    let hourly: OpenMeteoHourlyForecast
}

struct OpenMeteoCurrentWeather: Codable {
    let temperature: Double
    let weatherCode: Int
    let windSpeed: Double
    let windDirection: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case weatherCode = "weather_code"
        case windSpeed = "wind_speed_10m"
        case windDirection = "wind_direction_10m"
    }
}

struct OpenMeteoHourlyForecast: Codable {
    let precipitationProbability: [Int]

    enum CodingKeys: String, CodingKey {
        case precipitationProbability = "precipitation_probability"
    }
}
