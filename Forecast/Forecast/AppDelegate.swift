//
//  AppDelegate.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import Google

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.logger.logLevel = GAILogLevel.Error
        
        return true
    }

}

