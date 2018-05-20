//
//  AppDelegate.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window :UIWindow?

    
    //MARK: - Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = UIColor(red: 7/255, green: 91/255, blue: 167/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(red: 83/255, green: 167/255, blue: 243/255, alpha: 1.0) //.white 83 167 243
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor(red: 250/255, green: 255/255, blue: 252/255, alpha: 1.0)
        
        // Fabric with Crashlytics
        let isUserOptedOutofTracking = UserDefaults.standard.bool(forKey: "FabricOptOut")
        switch isUserOptedOutofTracking {
        case false:
            Fabric.with([Crashlytics.self])
        case true:
            break
        }
        
        return true
    }

}
