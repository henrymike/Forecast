//
//  NetworkManager.swift
//  SwiftTune
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    
    private var serverReach: Reachability?
    var serverAvailable = false
    
    func reachabilityChanged(note: NSNotification) {
        let reach = note.object as! Reachability
        serverAvailable = !(reach.currentReachabilityStatus().rawValue == NotReachable.rawValue)
        if serverAvailable {
            print("Changed: Server Available")
        } else {
            print("Changed: Server Not Available")
        }
    }
    
    override init() {
        super.init()
        print("Starting Network Manager")
        serverReach = Reachability(hostName: "www.google.com")
//        let dataManager = DataManager.sharedInstance
//        serverReach = Reachability(hostName: dataManager.baseURLString)
        serverReach?.startNotifier()
        NSNotificationCenter.defaultCenter() .addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
    }
}
