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
    @IBOutlet weak var locationLabel :UILabel!
    @IBOutlet weak var summaryLabel :UILabel!
    @IBOutlet weak var rainLabel :UILabel!
    @IBOutlet weak var windLabel :UILabel!
    @IBOutlet weak var iconImageView :UIImageView!
    @IBOutlet weak var forecastView :UIView!
    
    
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
        if let url = URL(string: "http://forecast.io") {
            let viewcont = SFSafariViewController(url: url)
            present(viewcont, animated: true, completion: nil)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: - Display Methods
    func displayCurrentForecast() {
        forecastView.isHidden = false
        temperatureLabel.text = "\(String (format: "%.0f", dataManager.forecast.temperature))°"
        print("Current Location: \(locManager.currentLocation)")
        summaryLabel.text = dataManager.forecast.summary
        rainLabel.text = "Rain: \(String (format: "%.0f", dataManager.forecast.precipProbability*100))%"
        windLabel.text = "Wind: \(String (format: "%.0f", dataManager.forecast.windSpeed))mph"
        iconImageView.image = UIImage(named: "\(dataManager.forecast.icon)")

        forecastView.reloadInputViews()
    }
    
    func newDataReceived() {
        print("New Data Received")
        displayCurrentForecast()
    }
    
    func newLocationReceived() {
        print("User Location Received")
        if networkManager.serverAvailable {
            dataManager.getDataFromServer(locManager.convertCoordinateToString(locManager.userLocationCoordinates))
        } else {
            print("Search: Server Not Available")
            alertManager.dataAlert()
        }
    }
    
    func reverseGeocodeReceived() {
        print("Reverse Geocoded Location Received")
        locationLabel.text = locManager.geocodedLocation
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

