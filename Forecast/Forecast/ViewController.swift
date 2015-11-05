//
//  ViewController.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    //MARK: - Properties
    var networkManager = NetworkManager.sharedInstance
    var dataManager = DataManager.sharedInstance
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
//            let address = "5194 Celtic Drive, North Charleston, SC 29405"
            dataManager.geocodeAddress(address)
        } else {
            print("Search: Server Not Available")
        }
    }
    
    //MARK: - Display Methods
    func displayCurrentForecast() {
        print("Current Forecast")
        forecastView.hidden = false
        print("Forecast Array:\(dataManager.forecastArray)")
        let forecast = dataManager.forecastArray[0]
        temperatureLabel.text = "\(forecast.temperature)°"
        locationLabel.text = searchBar.text
        summaryLabel.text = forecast.summary
        rainLabel.text = "Rain: \(forecast.precipProbability)%"
        windLabel.text = "Wind: \(forecast.windSpeed)mph"
        iconImageView.image = UIImage(named: "\(forecast.icon)")
        forecastView .reloadInputViews()
        
        
    }
    
    func newDataReceived() {
        print("New Data Received")
        displayCurrentForecast()
    }
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        dataManager.geocodeAddress("5194 Celtic Drive, North Charleston, SC 29405")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newDataReceived", name: "receivedDataFromServer", object: nil) // listens for fetch

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

