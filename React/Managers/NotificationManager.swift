//
//  NotificationManager.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import UserNotifications
import SwiftUI
import Combine

@MainActor
final class NotificationManager: NSObject, ObservableObject {

    static let reactNotificationIdentifier = "com.react.demo.incomingReact"

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var shouldOpenPlayback: Bool = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task { await self.refreshStatus() }
    }

    var isAuthorized: Bool {
        self.authorizationStatus == .authorized || self.authorizationStatus == .provisional
    }

    var isDenied: Bool {
        self.authorizationStatus == .denied
    }

    func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                await self.refreshStatus()
                if granted {
                    self.scheduleReactNotification()
                }
            } catch {
                await self.refreshStatus()
            }
        }
    }

    func scheduleReactNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.reactNotificationIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = "Yannick Juarez"
        content.body = "Yannick sent you a React 👀"
        content.sound = .default
        content.userInfo = ["action": "openReact"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.reactNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func openSettingsForNotifications() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.identifier == Self.reactNotificationIdentifier {
            Task { @MainActor in
                self.shouldOpenPlayback = true
            }
        }
        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
