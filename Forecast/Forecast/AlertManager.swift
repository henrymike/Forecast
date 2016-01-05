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
        let dataAlert = UIAlertController(title: "Data Error", message: "There was a problem retrieving weather data", preferredStyle: .Alert)
        dataAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//        self.presentViewController(dataAlert, animated: true, completion: nil)
        createAlertWindow(dataAlert)
    }
    
    func locServicesAlert() {
        let locServicesAlert = UIAlertController(title: "Location Services", message: "We need your location to get your local weather. Please enable Location Services in Settings", preferredStyle: .Alert)
        locServicesAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        createAlertWindow(locServicesAlert)
    }
    
    func createAlertWindow(alertName: UIViewController) {
        let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.presentViewController(alertName, animated: true, completion: nil)
    }
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
