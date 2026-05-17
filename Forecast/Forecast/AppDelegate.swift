//
//  AppDelegate.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window :UIWindow?

    
    //MARK: - Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(red: 7/255, green: 91/255, blue: 167/255, alpha: 1.0)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationBar.compactAppearance = navigationBarAppearance
        navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
        navigationBar.tintColor = UIColor(red: 83/255, green: 167/255, blue: 243/255, alpha: 1.0)

        UISearchTextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor(red: 250/255, green: 255/255, blue: 252/255, alpha: 1.0)

        return true
    }

}
