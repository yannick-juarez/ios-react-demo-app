//
//  PermissionsManager.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import AVFoundation
import Combine

@MainActor
final class PermissionsManager: ObservableObject {

    @Published private(set) var cameraStatus: AVAuthorizationStatus
    @Published private(set) var microphoneStatus: AVAudioSession.RecordPermission

    init() {
        self.cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.microphoneStatus = AVAudioSession.sharedInstance().recordPermission
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

    var protectionMessage: String {
        if self.shouldShowOpenSettingsAction {
            return "Vous devez activer la camera et le micro dans les reglages pour enregistrer votre reaction."
        }

        return "Vous devez autoriser la camera et le micro pour enregistrer votre reaction."
    }

    var actionTitle: LocalizedStringKey? {
        if self.areAllAuthorized {
            return nil
        }

        if self.shouldShowOpenSettingsAction {
            return "Open Settings"
        }

        return "Allow Camera & Microphone Access"
    }

    func refreshStatuses() {
        self.cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.microphoneStatus = AVAudioSession.sharedInstance().recordPermission
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
            _ = await AVCaptureDevice.requestAccess(for: .video)
        }

        if self.microphoneStatus == .undetermined {
            _ = await self.requestMicrophoneAccess()
        }

        self.refreshStatuses()
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        guard UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    private func requestMicrophoneAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
