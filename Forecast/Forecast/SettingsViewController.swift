//
//  SettingsViewController.swift
//  Forecast
//
//  Created by Mike Henry on 5/20/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import UIKit
import Crashlytics

class SettingsViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var privacySwitch: UISwitch! {
        didSet {
            privacySwitch.onTintColor = UIColor(red: 83/255, green: 167/255, blue: 243/255, alpha: 1.0)
            privacySwitch.tintColor = .white
        }
    }
    @IBOutlet weak var privacyLabel: UILabel!
    
    
    //MARK: - Interactivity Methods
    @IBAction func privacyOptOutSwitch(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            UserDefaults.standard.set(sender.isOn, forKey: "FabricOptOut")
            Answers.logCustomEvent(withName: "Fabric Opt-out", customAttributes: ["Status" : sender.isOn])
        case false:
            UserDefaults.standard.set(sender.isOn, forKey: "FabricOptOut")
            Answers.logCustomEvent(withName: "Fabric Opt-out", customAttributes: ["Status" : sender.isOn])
        }
    }
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserOptOutStatus()
    }
    
    private func checkUserOptOutStatus() {
        let isUserOptedOutofTracking = UserDefaults.standard.bool(forKey: "FabricOptOut")
        switch isUserOptedOutofTracking {
        case false:
            privacySwitch.isOn = false
        case true:
            privacySwitch.isOn = true
        }
    }
}
