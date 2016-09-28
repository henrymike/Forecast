//
//  AlertManager.swift
//  Forecast
//
//  Created by Mike Henry on 1/5/16.
//  Copyright © 2016 Mike Henry. All rights reserved.
//

import UIKit

class AlertManager: UIViewController {

    //MARK: - Properties
    static let sharedInstance = AlertManager()
    
    
    //MARK: - Alert Methods
    
    func dataAlert() {
        let dataAlert = UIAlertController(title: "Data Error", message: "There was a problem retrieving weather data", preferredStyle: .alert)
        dataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        createAlertWindow(dataAlert)
    }
    
    func locServicesAlert() {
        let locServicesAlert = UIAlertController(title: "Location Services", message: "We need your location to get your local weather. Please enable Location Services in Settings", preferredStyle: .alert)
        locServicesAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        createAlertWindow(locServicesAlert)
    }
    
    func createAlertWindow(_ alertName: UIViewController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertName, animated: true, completion: nil)
    }
    
}
