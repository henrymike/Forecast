//
//  AlertManager.swift
//  Forecast
//
//  Created by Mike Henry on 1/5/16.
//  Copyright © 2016 Mike Henry. All rights reserved.
//

import UIKit

class AlertManager: NSObject {

    //MARK: - Properties
    static let sharedInstance = AlertManager()
    
    
    //MARK: - Alert Methods
    
    func dataAlert() {
        let dataAlert = UIAlertController(title: "Data Error", message: "There was a problem retrieving weather data", preferredStyle: .alert)
        dataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        presentAlert(dataAlert)
    }
    
    func locServicesAlert() {
        let locServicesAlert = UIAlertController(title: "Location Services", message: "We need your location to get your local weather. Please enable Location Services in Settings", preferredStyle: .alert)
        locServicesAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        presentAlert(locServicesAlert)
    }
    
    private func presentAlert(_ alert: UIViewController) {
        DispatchQueue.main.async {
            guard let presenter = Self.topViewController() else {
                return
            }

            presenter.present(alert, animated: true, completion: nil)
        }
    }

    private static func topViewController() -> UIViewController? {
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        var topViewController = rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }

        return topViewController
    }
    
}
