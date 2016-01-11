//
//  ViewController.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import SafariServices

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
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if networkManager.serverAvailable {
            let address = searchBar.text!
            searchBar.resignFirstResponder()
            locManager.geocodeAddress(address)
        } else {
            print("Search: Server Not Available")
            alertManager.dataAlert()
        }
    }
    
    @IBAction func reloadCurrentWeather(sender: UIBarButtonItem) {
        searchBar.text = ""
        searchBar.placeholder = "Current Location"
        locManager.setUpLocationMonitoring()
    }
    
    @IBAction func creditsButtonPressed(sender: UIButton) {
        if let url = NSURL(string: "http://forecast.io") {
            let viewcont = SFSafariViewController(URL: url)
            presentViewController(viewcont, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Display Methods
    func displayCurrentForecast() {
        forecastView.hidden = false
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newDataReceived", name: "receivedDataFromServer", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newLocationReceived", name: "newUserLocationReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reverseGeocodeReceived", name: "reverseGeocodedLocationReceived", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}

