//
//  MainReactView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import CoreDomain
import DesignSystem
import CameraFeature
import AnalyticsKit
import Foundation

public struct ReactMainView: View {

    @State var react: React
    @StateObject private var permissionsManager: PermissionsManager
    @StateObject private var viewModel: ReactMainViewModel
    @Environment(\.scenePhase) private var scenePhase
    private let injectedPreviewState: ReactMainPreviewState?
    private let usesDummyCameraPreview: Bool

    let onReactionCaptured: (URL) -> Void
    let onCaptureIntent: () -> Void
    let onCaptureStarted: () -> Void
    let onCaptureInterrupted: () -> Void

    public init(
        react: React,
        permissionClient: CameraPermissionClient = .live,
        previewState: ReactMainPreviewState? = nil,
        usesDummyCameraPreview: Bool = false,
        onCaptureIntent: @escaping () -> Void = {},
        onCaptureStarted: @escaping () -> Void = {},
        onCaptureInterrupted: @escaping () -> Void = {},
        onReactionCaptured: @escaping (URL) -> Void
    ) {
        self._react = State(initialValue: react)
        self.onCaptureIntent = onCaptureIntent
        self.onCaptureStarted = onCaptureStarted
        self.onCaptureInterrupted = onCaptureInterrupted
        self.onReactionCaptured = onReactionCaptured
        self.injectedPreviewState = previewState
        self.usesDummyCameraPreview = usesDummyCameraPreview
        self._permissionsManager = StateObject(wrappedValue: PermissionsManager(permissionClient: permissionClient))
        self._viewModel = StateObject(wrappedValue: ReactMainViewModel())
    }

    public var body: some View {
        VStack {
            VStack {
                ReactSenderCapsule2(user: self.react.sender)
                ContentPreview(
                    react: self.react,
                    isBlurred: !self.viewModel.isRevealed,
                    countdownValue: self.viewModel.countdownValue
                )
                Text(
                    String(
                        format: String(
                            localized: "reaction.main.send_hint",
                            defaultValue: "Your reaction will be sent to %@",
                            bundle: .module
                        ),
                        locale: Locale.current,
                        self.react.sender.displayName
                    )
                )
                    .font(.subheadline)
            }
            .padding()

            ZStack {
                Group {
                    if self.usesDummyCameraPreview {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.black, .gray.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            }
                            .frame(width: 120, height: 120)
                    } else {
                        FrontCameraPreview(
                            radius: 60,
                            isRecording: self.viewModel.isRecording,
                            canStartRecording: self.viewModel.canStartRecording,
                            onRecordingStarted: {
                                self.onCaptureStarted()
                            },
                            onVideoReady: { url in
                                self.onReactionCaptured(url)
                            }
                        )
                    }
                }
                .padding(.top, -170)
                .opacity(self.viewModel.isRecording ? 1 : 0)
                .allowsHitTesting(false)

                ReactCaptureButton(isPressed: self.$viewModel.isRecording)
                    .disabled(!self.permissionsManager.areAllAuthorized)
                    .opacity(self.permissionsManager.areAllAuthorized ? 1 : 0.5)
            }
        }
        .environmentObject(self.permissionsManager)
        .animation(.easeIn(duration: 0.2), value: self.viewModel.isRecording)
        .onAppear {
            self.permissionsManager.refreshStatuses()
            if let injectedPreviewState {
                self.viewModel.applyPreviewState(injectedPreviewState)
            }
        }
        .onChange(of: self.scenePhase) { newPhase in
            guard newPhase == .active else {
                // If app goes background mid-capture, cancel safely and allow resume later.
                if self.viewModel.isRecording {
                    self.onCaptureInterrupted()
                }
                self.viewModel.isRecording = false
                return
            }

            self.permissionsManager.refreshStatuses()
        }
        .onChange(of: self.viewModel.isRecording) { newValue in
            guard self.injectedPreviewState == nil else { return }
            self.viewModel.handleRecordingChanged(newValue)
            if newValue {
                self.onCaptureIntent()
            }
        }
        .onDisappear {
            self.viewModel.onDisappear()
        }
    }
}

#Preview {
    ReactMainView(react: .sample, onReactionCaptured: { _ in })
        .preferredColorScheme(.dark)
}

#Preview("Permission Granted + Holding") {
    ReactMainView(
        react: .sample,
        permissionClient: CameraPermissionClient(
            cameraStatus: { .authorized },
            microphoneStatus: { .granted },
            requestCameraAccess: { true },
            requestMicrophoneAccess: { true },
            openAppSettings: {}
        ),
        previewState: ReactMainPreviewState(
            isRecording: true,
            isRevealed: true,
            canStartRecording: true,
            countdownValue: nil
        ),
        usesDummyCameraPreview: true,
        onReactionCaptured: { _ in }
    )
        .preferredColorScheme(.dark)
}
