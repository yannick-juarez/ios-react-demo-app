//
//  AnalyticsProvider.swift
//  AnalyticsKit
//

/// A type that can receive analytics events.
public protocol AnalyticsProvider: Sendable {
    func track(eventName: String, properties: [String: String])
}
