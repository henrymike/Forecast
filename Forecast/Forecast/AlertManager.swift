//
//  AlertManager.swift
//  Forecast
//
//  Created by Mike Henry on 1/5/16.
//  Copyright © 2016 Mike Henry. All rights reserved.
//

import UIKit

class AlertManager: UIViewController {

    static let sharedInstance = AlertManager()
    
    
    //MARK: Alert Methods
    
    func testAlert() {
        let testAlert = UIAlertController(title: "Data Error", message: "There was a problem retrieving weather data", preferredStyle: .Alert)
        testAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(testAlert, animated: true, completion: nil)
    }
    
    func locServicesAlert() {
        let locServicesAlert = UIAlertController(title: "Location Services", message: "We need your location to get your local weather. Please enable Location Services in Settings", preferredStyle: .Alert)
        locServicesAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(locServicesAlert, animated: true, completion: nil)
    }
    
    
    
    //MARK: Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
