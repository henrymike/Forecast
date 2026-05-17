//
//  ForecastViewModel.swift
//  Forecast
//
//  Created by Codex on 5/17/26.
//  Copyright © 2026 Mike Henry. All rights reserved.
//

import Foundation

final class ForecastViewModel: NSObject, ObservableObject {

    enum UnitType: String, CaseIterable, Identifiable {
        case standard = "F"
        case metric = "C"

        var id: String { rawValue }
    }

    struct ForecastAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    @Published var forecast: Weather?
    @Published var locationName = ""
    @Published var searchText = ""
    @Published var selectedUnit: UnitType = .standard
    @Published var isLoading = false
    @Published var alert: ForecastAlert?

    private let locManager = LocationManager.sharedInstance

    override init() {
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newLocationReceived),
            name: NSNotification.Name(rawValue: "newUserLocationReceived"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reverseGeocodeReceived),
            name: NSNotification.Name(rawValue: "reverseGeocodedLocationReceived"),
            object: nil
        )

        #if targetEnvironment(simulator)
        applyScreenshotStateIfNeeded()
        #endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadCurrentLocation() {
        searchText = ""
        isLoading = true
        locManager.setUpLocationMonitoring()
    }

    func search() {
        let address = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return }

        isLoading = true
        locManager.geocodeAddress(address)
    }

    func clearSearch() {
        searchText = ""
    }

    var temperatureText: String {
        guard let temperature = forecast?.temperature else { return "--" }

        switch selectedUnit {
        case .metric:
            return String(format: "%.0f", (temperature - 32) * 5 / 9)
        case .standard:
            return String(format: "%.0f", temperature)
        }
    }

    var unitText: String {
        selectedUnit.rawValue
    }

    var summaryText: String {
        forecast?.summary ?? "Forecast"
    }

    var precipitationText: String {
        guard let precipitation = forecast?.precipitation else { return "--" }
        return String(format: "%.0f%%", precipitation * 100)
    }

    var windText: String {
        guard let windSpeed = forecast?.windSpeed else { return "--" }

        let direction = forecast?.windDirection.map(windDirection) ?? ""
        switch selectedUnit {
        case .metric:
            return "\(direction) \(String(format: "%.0f", windSpeed * 1.609344)) kph"
        case .standard:
            return "\(direction) \(String(format: "%.0f", windSpeed)) mph"
        }
    }

    var weatherIconName: String {
        forecast?.icon ?? "cloud.sun.fill"
    }

    var providerName: String {
        forecast?.providerName ?? "Weather"
    }

    var attributionURL: URL? {
        forecast?.attributionURL
    }

    @objc private func newLocationReceived() {
        let coordinateString = locManager.convertCoordinateToString(locManager.userLocationCoordinates)

        DataManager.getForecastData(coordinateString: coordinateString) { [weak self] forecastData, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let forecastData = forecastData {
                    self.forecast = forecastData
                    return
                }

                self.alert = ForecastAlert(
                    title: "Weather Unavailable",
                    message: error?.localizedDescription ?? "There was a problem retrieving weather data."
                )
            }
        }
    }

    @objc private func reverseGeocodeReceived() {
        locationName = locManager.geocodedLocation
    }

    private func windDirection(_ compass: Double) -> String {
        switch compass {
        case 0...22, 338...359:
            return "N"
        case 23...66:
            return "NE"
        case 67...111:
            return "E"
        case 112...156:
            return "SE"
        case 157...202:
            return "S"
        case 203...246:
            return "SW"
        case 247...291:
            return "W"
        case 292...337:
            return "NW"
        default:
            return ""
        }
    }

    #if targetEnvironment(simulator)
    private func applyScreenshotStateIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-ForecastScreenshotMode") else { return }

        let demoForecast = Weather()
        demoForecast.summary = screenshotArgumentValue(after: "-ForecastScreenshotSummary") ?? "Mostly Sunny"
        demoForecast.icon = screenshotArgumentValue(after: "-ForecastScreenshotIcon") ?? "sun.max.fill"
        demoForecast.precipitation = screenshotDoubleValue(after: "-ForecastScreenshotPrecipitation") ?? 0.08
        demoForecast.temperature = screenshotDoubleValue(after: "-ForecastScreenshotTemperature") ?? 72
        demoForecast.humidity = screenshotDoubleValue(after: "-ForecastScreenshotHumidity") ?? 0.42
        demoForecast.windSpeed = screenshotDoubleValue(after: "-ForecastScreenshotWindSpeed") ?? 9
        demoForecast.windDirection = screenshotDoubleValue(after: "-ForecastScreenshotWindDirection") ?? 245
        demoForecast.providerName = "Apple Weather"

        forecast = demoForecast
        locationName = screenshotArgumentValue(after: "-ForecastScreenshotLocation") ?? "Asheville, NC"
        searchText = screenshotArgumentValue(after: "-ForecastScreenshotSearchText") ?? ""
        selectedUnit = arguments.contains("-ForecastScreenshotMetric") ? .metric : .standard
        isLoading = false
    }

    private func screenshotArgumentValue(after argument: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: argument) else { return nil }

        let valueIndex = arguments.index(after: index)
        guard arguments.indices.contains(valueIndex) else { return nil }

        return arguments[valueIndex]
    }

    private func screenshotDoubleValue(after argument: String) -> Double? {
        guard let value = screenshotArgumentValue(after: argument) else { return nil }
        return Double(value)
    }
    #endif
}
