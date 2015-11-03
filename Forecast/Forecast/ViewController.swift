//
//  ViewController.swift
//  Forecast
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Properties
    var networkManager = NetworkManager.sharedInstance
    var dataManager = DataManager.sharedInstance
    
    
    //MARK: - Interactivity Methods
    @IBAction func searchButtonPressed(sender: UIBarButtonItem) {
        if networkManager.serverAvailable {
            dataManager.getDataFromServer()
        } else {
            print("Search: Server Not Available")
        }
    }
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

