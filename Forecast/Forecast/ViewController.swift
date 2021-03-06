//
//  ViewController.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import SafariServices
import Crashlytics

class ViewController: UIViewController, UISearchBarDelegate {

    //MARK: - Properties
    var networkManager = NetworkManager.sharedInstance
    var dataManager = DataManager.sharedInstance
    var locManager = LocationManager.sharedInstance
    var alertManager = AlertManager.sharedInstance
    @IBOutlet weak var searchBar :UISearchBar!
    @IBOutlet weak var temperatureLabel :UILabel!
    @IBOutlet weak var locationLabel :UILabel! {
        didSet {
            locationLabel.text = "" //Set to blank until data comes back
        }
    }
    @IBOutlet weak var summaryLabel :UILabel!
    @IBOutlet weak var rainLabel :UILabel!
    @IBOutlet weak var windLabel :UILabel!
    @IBOutlet weak var iconImageView :UIImageView!
    @IBOutlet weak var forecastView :UIView!
    var forecast = Weather()
    private var windDirection :String!
    private var currentTemperatureFormat :UnitsType = .standard
    
    
    //MARK: - Interactivity Methods        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if networkManager.serverAvailable {
            let address = searchBar.text!
            searchBar.resignFirstResponder()
            locManager.geocodeAddress(address)
            Answers.logCustomEvent(withName: "Search Query", customAttributes: ["Entered Text" : address])
        } else {
            print("Search: Server Not Available")
            alertManager.dataAlert()
        }
    }
    
    @IBAction func reloadCurrentWeather(_ sender: UIBarButtonItem) {
        searchBar.text = ""
        searchBar.placeholder = "Current Location"
        locManager.setUpLocationMonitoring()
    }
    
    @IBAction func creditsButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://darksky.net/poweredby/") {
            let viewcont = SFSafariViewController(url: url)
            present(viewcont, animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: - Unit Type Support
    private enum UnitsType {
        case metric
        case standard
    }
    
    @IBAction private func switchUnitTypes() {
        switch currentTemperatureFormat {
        case .metric:
            print("Switched to F")
            currentTemperatureFormat = .standard
            displayCurrentForecast()
        case .standard:
            print("Switched to C")
            currentTemperatureFormat = .metric
            displayCurrentForecast()
        }
    }
    
    
    //MARK: - Display Methods
    func createAttributedString(temperature: Double, unitType: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        let temperatureFont = UIFont(name: "KhmerSangamMN", size: 98.0)
        let temperatureColor = UIColor(red: 250, green: 255, blue: 252, alpha: 1)
        let temperatureAttributedString = NSAttributedString(string: "\(String (format: "%.0f", temperature))°", attributes: [NSAttributedString.Key.font: temperatureFont!, NSAttributedString.Key.foregroundColor: temperatureColor])
        
        let unitTypeFont = UIFont(name: "KhmerSangamMN", size: 72.0)
        let unitTypeColor = UIColor(red: 74, green: 163, blue: 247, alpha: 1)
        let unitTypeAttributedString = NSAttributedString(string: "\(unitType)", attributes: [NSAttributedString.Key.font : unitTypeFont!, NSAttributedString.Key.foregroundColor : unitTypeColor])
        
        attributedString.append(temperatureAttributedString)
        attributedString.append(unitTypeAttributedString)
        
        return attributedString
    }
    
    
    private func displayCurrentForecast() {
        forecastView.isHidden = false
        
        //Temperature Display C/F
        switch currentTemperatureFormat {
        case .metric:
            let celciusTemp = (Double(((forecast.temperature!)-32)*5)/9)
            print("Calculated Temp C:\(celciusTemp)")
            let generatedLabel = createAttributedString(temperature: celciusTemp, unitType: "C")
            temperatureLabel.attributedText = generatedLabel
        case .standard:
            let generatedLabel = createAttributedString(temperature: forecast.temperature!, unitType: "F")
            temperatureLabel.attributedText = generatedLabel
        }
        
        print("Current Location: \(locManager.currentLocation)")
        summaryLabel.text = forecast.summary
        rainLabel.text = "Rain: \(String (format: "%.0f", forecast.precipitation!*100))%"
        
        //Wind Speed Display kph/mph
        if let windDirection = forecast.windDirection {
            let direction = determineWindDirection(compass: windDirection)
            switch currentTemperatureFormat {
            case .metric:
                let windKPH = ((forecast.windSpeed!)*1.609344)
                windLabel.text = "Wind: \(direction) \(String (format: "%.0f", windKPH))kph"
            case .standard:
                windLabel.text = "Wind: \(direction) \(String (format: "%.0f", forecast.windSpeed!))mph"
            }
        }

        
        iconImageView.image = UIImage(named: "\(forecast.icon!)")
        forecastView.reloadInputViews()
    }
    
    private func determineWindDirection(compass: Double) -> String {
        switch compass {
        case 0...22:
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
        case 338...359:
            return "N"
        default:
            return ""
        }
    }
    
    @objc func newDataReceived() {
        print("New Data Received")
        displayCurrentForecast()
    }
    
    @objc func newLocationReceived() {
        print("User Location Received")
//        if networkManager.serverAvailable {
//            dataManager.getDataFromServer(locManager.convertCoordinateToString(locManager.userLocationCoordinates))
            
            DataManager.getForecastData(coordinateString: locManager.convertCoordinateToString(locManager.userLocationCoordinates)) { (forecastData, error) in
                if let _ = error {
                    //handle error?
                } else if let forecast = forecastData {
                    DispatchQueue.main.async() {
                        [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.forecast = forecast
//                        DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "receivedDataFromServer"), object: nil))
//                                        }
//                        strongSelf.displayCurrentForecast()
                    }
                }
//                print("Data: \(data)")
            }
//        }
    }
    
    @objc func reverseGeocodeReceived() {
        print("Reverse Geocoded Location Received")
        locationLabel.text = locManager.geocodedLocation
        Answers.logCustomEvent(withName: "Location", customAttributes: ["Returned Location" : locManager.geocodedLocation])
    }

    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.setUpLocationMonitoring()
        
        //Dismiss keyboard from Search bar on tap gesture
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.newDataReceived), name: NSNotification.Name(rawValue: "receivedDataFromServer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.newLocationReceived), name: NSNotification.Name(rawValue: "newUserLocationReceived"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reverseGeocodeReceived), name: NSNotification.Name(rawValue: "reverseGeocodedLocationReceived"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
