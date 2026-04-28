//
//  ConsoleAnalyticsProvider.swift
//  AnalyticsKit
//

import os

/// Logs every event to the unified logging system. Use in debug builds.
public struct ConsoleAnalyticsProvider: AnalyticsProvider {
    private let logger = Logger(
        subsystem: "com.yannickjuarez.React.Analytics",
        category: "Events"
    )

    public init() {}

    public func track(eventName: String, properties: [String: String]) {
        if properties.isEmpty {
            logger.debug("[analytics] event=\(eventName, privacy: .public)")
            return
        }

        let props = properties
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: ",")
        logger.debug("[analytics] event=\(eventName, privacy: .public) \(props, privacy: .public)")
    }
}
