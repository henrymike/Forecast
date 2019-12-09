//
//  NetworkManager.swift
//  SwiftTune
//
//  Created by Mike Henry on 11/3/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    //MARK: - Reachability
    static let sharedInstance = NetworkManager()
    let dataManager = DataManager.sharedInstance
    fileprivate var serverReach: Reachability?
    var serverAvailable = false
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reach = note.object as! Reachability
        serverAvailable = !(reach.currentReachabilityStatus().rawValue == NotReachable.rawValue)
        if serverAvailable {
            print("Changed: Server Available")
        } else {
            print("Changed: Server Not Available")
            serverAvailable = false
        }
    }
    
    override init() {
        super.init()
        print("Starting Network Manager")
//        serverReach = Reachability(hostName: "\(dataManager.baseURLString)" )
//        serverReach?.startNotifier()
//        NotificationCenter.default .addObserver(self, selector: #selector(NetworkManager.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
}
