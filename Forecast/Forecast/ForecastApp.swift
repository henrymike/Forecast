//
//  ForecastApp.swift
//  Forecast
//
//  Created by Codex on 5/17/26.
//  Copyright © 2026 Mike Henry. All rights reserved.
//

import SwiftUI

@main
struct ForecastApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ForecastView()
        }
    }
}
