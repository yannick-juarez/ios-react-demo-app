//
//  ReactApp.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import AnalyticsKit

@main
struct DemoApp: App {
    init() {
        // Swap with AmplitudeAnalyticsProvider() once SDK is wired.
        AnalyticsService.shared.setProvider(ConsoleAnalyticsProvider())
    }

    var body: some Scene {
        WindowGroup {
            DemoAppRootView(dependencies: .live)
        }
    }
}
