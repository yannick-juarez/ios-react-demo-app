//
//  NoopAnalyticsProvider.swift
//  AnalyticsKit
//

/// Silently discards all events. Use in unit tests.
public struct NoopAnalyticsProvider: AnalyticsProvider {
    public init() {}

    public func track(eventName: String, properties: [String: String]) {}
}
