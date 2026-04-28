//
//  NotificationManager.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import UserNotifications
import Combine

@MainActor
public final class ReactNotificationScheduler: NSObject, ObservableObject {

    public enum Route: Equatable {
        case incomingReact
        case playback
    }

    public nonisolated static let incomingReactNotificationIdentifier = "com.react.demo.incomingReact"
    public nonisolated static let playbackNotificationIdentifier = "com.react.demo.playback"

    @Published public private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published public private(set) var pendingRoute: Route?

    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task { await self.refreshStatus() }
    }

    public var isAuthorized: Bool {
        self.authorizationStatus == .authorized || self.authorizationStatus == .provisional
    }

    public var isDenied: Bool {
        self.authorizationStatus == .denied
    }

    public func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
    }

    public func requestAuthorization() {
        Task {
            do {
                _ = try await UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                await self.refreshStatus()
            } catch {
                await self.refreshStatus()
            }
        }
    }

    public func scheduleIncomingReactNotification(after delay: TimeInterval = 5) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.incomingReactNotificationIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = "Yannick Juarez"
        content.body = "You received a React !"
        content.sound = .default
        content.userInfo = ["action": "openIncomingReact"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.incomingReactNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    public func schedulePlaybackNotification(senderName: String, after delay: TimeInterval = 3) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.playbackNotificationIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = "\(senderName) has seen and reacted to your content"
        content.sound = .default
        content.userInfo = ["action": "openPlayback"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.playbackNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    public func consumePendingRoute() {
        self.pendingRoute = nil
    }
}

extension ReactNotificationScheduler: UNUserNotificationCenterDelegate {

    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier

        Task { @MainActor in
            switch identifier {
            case Self.incomingReactNotificationIdentifier:
                self.pendingRoute = .incomingReact
            case Self.playbackNotificationIdentifier:
                self.pendingRoute = .playback
            default:
                break
            }
        }

        completionHandler()
    }

    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
