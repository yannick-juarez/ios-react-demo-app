//
//  AmplitudeAnalyticsProvider.swift
//  AnalyticsKit
//
//  HOW TO ENABLE AMPLITUDE
//  ────────────────────────
//  1. In AnalyticsKit/Package.swift, uncomment:
//       .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.7.0")
//     and in the AnalyticsKit target dependencies:
//       .product(name: "AmplitudeSwift", package: "Amplitude-Swift")
//
//  2. In App startup (ReactApp.swift), replace ConsoleAnalyticsProvider with:
//       AnalyticsService.shared.setProvider(
//           AmplitudeAnalyticsProvider(apiKey: Secrets.amplitudeAPIKey)
//       )
//
//  3. Uncomment the implementation body below (the `#if canImport` block).
//

// #if canImport(AmplitudeSwift)
// import AmplitudeSwift
//
// /// Forwards every analytics event to Amplitude via the Amplitude-Swift SDK.
// public struct AmplitudeAnalyticsProvider: AnalyticsProvider {
//     private let amplitude: Amplitude
//
//     public init(apiKey: String) {
//         amplitude = Amplitude(
//             configuration: Configuration(
//                 apiKey: apiKey,
//                 flushIntervalMillis: 30_000,
//                 flushQueueSize: 30,
//                 minIdLength: 1
//             )
//         )
//     }
//
//     public func track(eventName: String, properties: [String: String]) {
//         amplitude.track(
//             eventType: eventName,
//             eventProperties: properties
//         )
//     }
// }
// #endif

/// Stub — keeps the rest of the codebase compiling before the SDK is wired in.
/// Replace with the `#if canImport(AmplitudeSwift)` block above once the dep is added.
public struct AmplitudeAnalyticsProvider: AnalyticsProvider {
    public let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func track(eventName: String, properties: [String: String]) {
        // Stub — see file header for activation instructions.
    }
}
