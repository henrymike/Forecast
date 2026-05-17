//
//  Weather.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import Foundation
import WeatherKit

class Weather: NSObject {
    var summary: String?
    var icon: String?
    var precipitation: Double?
    var temperature: Double?
    var humidity: Double?
    var windSpeed: Double?
    var windDirection: Double?
    var providerName: String?
    var attributionURL: URL?

    override init() {
        super.init()
    }

    init(weatherKitCurrent current: CurrentWeather, hourlyForecast: Forecast<HourWeather>) {
        self.summary = current.condition.description
        self.icon = current.symbolName
        self.precipitation = hourlyForecast.forecast.first?.precipitationChance
        self.temperature = current.temperature.converted(to: .fahrenheit).value
        self.humidity = current.humidity
        self.windSpeed = current.wind.speed.converted(to: .milesPerHour).value
        self.windDirection = current.wind.direction.converted(to: .degrees).value
        self.providerName = "Apple Weather"
    }
}
