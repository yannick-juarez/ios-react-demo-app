//
//  CameraPermissionClient.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import AVFoundation
import UIKit

public struct CameraPermissionClient: @unchecked Sendable {
    public let cameraStatus: @Sendable () -> AVAuthorizationStatus
    public let microphoneStatus: @Sendable () -> AVAudioSession.RecordPermission
    public let requestCameraAccess: @Sendable () async -> Bool
    public let requestMicrophoneAccess: @Sendable () async -> Bool
    public let openAppSettings: @Sendable () -> Void

    public init(
        cameraStatus: @escaping @Sendable () -> AVAuthorizationStatus,
        microphoneStatus: @escaping @Sendable () -> AVAudioSession.RecordPermission,
        requestCameraAccess: @escaping @Sendable () async -> Bool,
        requestMicrophoneAccess: @escaping @Sendable () async -> Bool,
        openAppSettings: @escaping @Sendable () -> Void
    ) {
        self.cameraStatus = cameraStatus
        self.microphoneStatus = microphoneStatus
        self.requestCameraAccess = requestCameraAccess
        self.requestMicrophoneAccess = requestMicrophoneAccess
        self.openAppSettings = openAppSettings
    }

    public static let live = CameraPermissionClient(
        cameraStatus: {
            AVCaptureDevice.authorizationStatus(for: .video)
        },
        microphoneStatus: {
            AVAudioSession.sharedInstance().recordPermission
        },
        requestCameraAccess: {
            await AVCaptureDevice.requestAccess(for: .video)
        },
        requestMicrophoneAccess: {
            await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        },
        openAppSettings: {
            Task { @MainActor in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingsURL)
                else {
                    return
                }

                UIApplication.shared.open(settingsURL)
            }
        }
    )
}
