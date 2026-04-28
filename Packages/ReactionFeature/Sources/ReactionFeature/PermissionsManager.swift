//
//  PermissionsManager.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import AVFoundation
import Combine
import Foundation

@MainActor
public final class PermissionsManager: ObservableObject {

    private let permissionClient: CameraPermissionClient

    @Published public private(set) var cameraStatus: AVAuthorizationStatus
    @Published public private(set) var microphoneStatus: AVAudioSession.RecordPermission

    public init(permissionClient: CameraPermissionClient = .live) {
        self.permissionClient = permissionClient
        self.cameraStatus = permissionClient.cameraStatus()
        self.microphoneStatus = permissionClient.microphoneStatus()
    }

    var areAllAuthorized: Bool {
        self.cameraStatus == .authorized && self.microphoneStatus == .granted
    }

    var shouldShowAllowAction: Bool {
        self.cameraStatus == .notDetermined || self.microphoneStatus == .undetermined
    }

    var shouldShowOpenSettingsAction: Bool {
        !self.areAllAuthorized && !self.shouldShowAllowAction
    }

    public var protectionMessage: String {
        if self.shouldShowOpenSettingsAction {
            return String(
                localized: "reaction.permissions.enable_in_settings",
                defaultValue: "You must enable the camera and microphone in settings to record your reaction.",
                bundle: .module
            )
        }

        return String(
            localized: "reaction.permissions.allow_access",
            defaultValue: "You must allow camera and microphone access to record your reaction.",
            bundle: .module
        )
    }

    public var actionTitle: String? {
        if self.areAllAuthorized {
            return nil
        }

        if self.shouldShowOpenSettingsAction {
            return String(
                localized: "reaction.permissions.open_settings",
                defaultValue: "Open Settings",
                bundle: .module
            )
        }

        return String(
            localized: "reaction.permissions.allow_button",
            defaultValue: "Allow Camera & Microphone Access",
            bundle: .module
        )
    }

    public func refreshStatuses() {
        self.cameraStatus = self.permissionClient.cameraStatus()
        self.microphoneStatus = self.permissionClient.microphoneStatus()
    }

    func handlePrimaryAction() {
        if self.shouldShowOpenSettingsAction {
            self.openAppSettings()
            return
        }

        Task {
            await self.requestRequiredPermissions()
        }
    }

    func requestRequiredPermissions() async {
        if self.cameraStatus == .notDetermined {
            _ = await self.permissionClient.requestCameraAccess()
        }

        if self.microphoneStatus == .undetermined {
            _ = await self.requestMicrophoneAccess()
        }

        self.refreshStatuses()
    }

    private func openAppSettings() {
        self.permissionClient.openAppSettings()
    }

    private func requestMicrophoneAccess() async -> Bool {
        await self.permissionClient.requestMicrophoneAccess()
    }
}
