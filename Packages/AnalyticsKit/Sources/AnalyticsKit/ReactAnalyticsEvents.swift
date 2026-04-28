//
//  ReactAnalyticsEvents.swift
//  AnalyticsKit
//

/// Typed catalog of all analytics event names used in the React loop.
public enum ReactAnalyticsEvents {
    // MARK: — Share Extension
    public static let shareExtensionOpened    = "share_extension_opened"
    public static let shareTargetSelected     = "share_target_selected"
    public static let shareSent               = "share_sent"
    public static let shareNotificationSent   = "share_notification_sent"

    // MARK: — Receiver
    public static let shareLockScreenOpened   = "share_lock_screen_opened"
    public static let reactionCaptureStarted  = "reaction_capture_started"
    public static let reactionCaptureCompleted = "reaction_capture_completed"
    public static let reactionCaptureAbandoned = "reaction_capture_abandoned"
    public static let unlockSuccess           = "unlock_success"
    public static let unlockFailed            = "unlock_failed"

    // MARK: — Loop return
    public static let loopReturnSent          = "loop_return_sent"
    public static let loopReturnOpened        = "loop_return_opened"

    // MARK: — Helpers
    public static func payloadSizeBucket(bytes: Int) -> String {
        switch bytes {
        case ..<250_000:      return "<250kb"
        case ..<1_000_000:    return "250kb-1mb"
        case ..<5_000_000:    return "1mb-5mb"
        case ..<15_000_000:   return "5mb-15mb"
        default:              return ">=15mb"
        }
    }
}
