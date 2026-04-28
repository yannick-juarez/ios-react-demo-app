//
//  AnalyticsService.swift
//  AnalyticsKit
//

import Foundation

/// Thread-safe analytics dispatcher. Configure the active provider once at startup.
public final class AnalyticsService: @unchecked Sendable {
    public static let shared = AnalyticsService(provider: ConsoleAnalyticsProvider())

    private let lock = NSLock()
    private var provider: any AnalyticsProvider

    public init(provider: any AnalyticsProvider) {
        self.provider = provider
    }

    public func setProvider(_ provider: any AnalyticsProvider) {
        lock.lock()
        self.provider = provider
        lock.unlock()
    }

    public func track(_ eventName: String, properties: [String: String] = [:]) {
        lock.lock()
        let current = provider
        lock.unlock()
        current.track(eventName: eventName, properties: properties)
    }
}
