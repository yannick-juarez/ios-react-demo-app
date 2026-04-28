//
//  AppRootView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import UserNotifications
import CoreDomain
import CoreInfrastructure
import CameraFeature
import ReactionFeature
import AnalyticsKit

struct DemoAppRootView: View {

    @StateObject private var notificationManager: ReactNotificationScheduler
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    private let dependencies: AppDependencies

    @State private var currentReact: React?
    @State private var draftReactionVideoURL: URL?
    @State private var isIncomingReactPresented: Bool = false
    @State private var isPlaybackPresented: Bool = false
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self._notificationManager = StateObject(wrappedValue: dependencies.notificationScheduler)
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack {
                Image(systemName: "link")
                    .font(.largeTitle)
                Text("Welcome on React feature demo app")
                    .font(.title2.bold())
            }
            
            Text("1. Go to Photos app")
            Text("2. Click on a picture you want to share")
            Text("3. Select React app")


            
            if self.notificationPermissionStatus != .authorized {
                Divider()
                    .padding()
                VStack(spacing: 8) {
                    Text("Notifications")
                        .font(.headline)
                    Text("This demo app needs notifications permissions")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    if self.notificationPermissionStatus == .denied {
                        Button(action: self.openAppSettings) {
                            Text("Open Settings")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .padding(.horizontal)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
                        }
                    } else {
                        Button(action: self.requestNotificationPermission) {
                            Text("Allow")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .padding(.horizontal)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
        .padding()
        .multilineTextAlignment(.center)
        .environmentObject(self.notificationManager)
        .onAppear {
            self.checkNotificationPermissionStatus()
            self.processPendingNavigation()
        }
        .onChange(of: self.scenePhase) { newPhase in
            guard newPhase == .active else { return }
            self.checkNotificationPermissionStatus()
            self.processPendingNavigation()
        }
        .onChange(of: self.notificationManager.pendingRoute) { route in
            guard let route else { return }
            self.handle(route: route)
            self.notificationManager.consumePendingRoute()
        }
        .fullScreenCover(isPresented: self.$isIncomingReactPresented) {
            if let currentReact {
                IncomingReactFlowView(
                    react: currentReact,
                    cameraPermissionClient: self.dependencies.cameraPermissionClient,
                    onClose: {
                        self.dismissIncomingReact()
                    },
                    onCaptureAbandoned: { react, abandonStep in
                        AnalyticsService.shared.track(
                            ReactAnalyticsEvents.reactionCaptureAbandoned,
                            properties: [
                                "share_id": react.id.uuidString,
                                "receiver_id": User.sample.id.uuidString,
                                "abandon_step": abandonStep,
                                "attempt_index": "1",
                            ]
                        )
                    },
                    onReactionSent: { react, videoURL in
                        self.handleReactionSent(for: react, videoURL: videoURL)
                    }
                )
            }
        }
        .sheet(isPresented: self.$isPlaybackPresented, onDismiss: {
            self.currentReact = nil
        }) {
            if let currentReact, let responseURL = currentReact.response {
                ReactPlaybackView(
                    react: currentReact,
                    videoURL: responseURL,
                    onFinished: {
                        self.isPlaybackPresented = false
                    }
                )
            }
        }
    }

    private func handle(route: ReactNotificationScheduler.Route) {
        switch route {
        case .incomingReact:
            self.presentIncomingReactIfNeeded()
        case .playback:
            self.presentPlaybackIfNeeded()
        }
    }

    private func checkNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.checkNotificationPermissionStatus()
            }
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: "app-settings:") else { return }
        self.openURL(settingsURL)
    }

    private func processPendingNavigation() {
        if let pendingRoute = self.notificationManager.pendingRoute {
            self.handle(route: pendingRoute)
            self.notificationManager.consumePendingRoute()
            return
        }

        guard !self.isIncomingReactPresented,
              !self.isPlaybackPresented,
              self.dependencies.loadInboxUseCase.hasPendingDraft()
        else { return }

        self.presentIncomingReactIfNeeded()
    }

    private func presentIncomingReactIfNeeded() {
        guard let react = self.dependencies.loadInboxUseCase.execute() else { return }

        self.currentReact = react
        self.draftReactionVideoURL = nil
        self.isPlaybackPresented = false
        self.isIncomingReactPresented = true

        AnalyticsService.shared.track(
            ReactAnalyticsEvents.shareLockScreenOpened,
            properties: [
                "share_id": react.id.uuidString,
                "receiver_id": User.sample.id.uuidString,
                "open_source": "inbox",
            ]
        )
    }

    private func presentPlaybackIfNeeded() {
        guard let react = self.dependencies.loadInboxUseCase.loadLatest(), react.response != nil else { return }

        self.currentReact = react
        self.isIncomingReactPresented = false
        self.isPlaybackPresented = true

        AnalyticsService.shared.track(
            ReactAnalyticsEvents.loopReturnOpened,
            properties: [
                "share_id": react.id.uuidString,
                "sender_id": react.sender.id.uuidString,
                "content_type": "image",
            ]
        )
    }

    private func dismissIncomingReact() {
        self.isIncomingReactPresented = false
        self.draftReactionVideoURL = nil
        self.currentReact = nil
    }

    private func handleReactionSent(for react: React, videoURL: URL) {
        do {
            let storedReact = try self.dependencies.recordReactionUseCase.execute(videoURL: videoURL, for: react)
            let unlockedReact = self.dependencies.markReactAsUnlockedUseCase.execute(storedReact)
            self.currentReact = unlockedReact
            self.notificationManager.schedulePlaybackNotification(senderName: unlockedReact.sender.displayName)

            AnalyticsService.shared.track(
                ReactAnalyticsEvents.unlockSuccess,
                properties: [
                    "share_id": unlockedReact.id.uuidString,
                    "receiver_id": User.sample.id.uuidString,
                ]
            )
            AnalyticsService.shared.track(
                ReactAnalyticsEvents.loopReturnSent,
                properties: [
                    "share_id": unlockedReact.id.uuidString,
                    "sender_id": unlockedReact.sender.id.uuidString,
                    "receiver_id": User.sample.id.uuidString,
                    "transport_status": "scheduled",
                ]
            )
        } catch {
            AnalyticsService.shared.track(
                ReactAnalyticsEvents.unlockFailed,
                properties: [
                    "share_id": react.id.uuidString,
                    "receiver_id": User.sample.id.uuidString,
                    "error_code": String(describing: error),
                    "retry_available": "true",
                ]
            )
        }

        self.dismissIncomingReact()
    }
}

private struct IncomingReactFlowView: View {

    let react: React
    let cameraPermissionClient: CameraPermissionClient
    let onClose: () -> Void
    let onCaptureAbandoned: (React, String) -> Void
    let onReactionSent: (React, URL) -> Void

    @StateObject private var flowViewModel: ReactionFlowViewModel
    @State private var capturedVideoURL: URL?

    init(
        react: React,
        cameraPermissionClient: CameraPermissionClient,
        onClose: @escaping () -> Void,
        onCaptureAbandoned: @escaping (React, String) -> Void,
        onReactionSent: @escaping (React, URL) -> Void
    ) {
        self.react = react
        self.cameraPermissionClient = cameraPermissionClient
        self.onClose = onClose
        self.onCaptureAbandoned = onCaptureAbandoned
        self.onReactionSent = onReactionSent
        self._flowViewModel = StateObject(wrappedValue: ReactionFlowViewModel(initialState: .locked(react: react)))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch self.flowViewModel.state {
                case .locked(let react), .countingDown(let react, _), .recording(let react):
                    ReactMainView(
                        react: react,
                        permissionClient: self.cameraPermissionClient,
                        onCaptureIntent: {
                            if case .locked(let lockedReact) = self.flowViewModel.state {
                                self.flowViewModel.transition(to: .countingDown(react: lockedReact, remaining: 3))
                            }
                        },
                        onCaptureStarted: {
                            if case .countingDown(let countDownReact, _) = self.flowViewModel.state {
                                self.flowViewModel.transition(to: .recording(react: countDownReact))
                            } else if case .locked(let lockedReact) = self.flowViewModel.state {
                                self.flowViewModel.transition(to: .countingDown(react: lockedReact, remaining: 3))
                                self.flowViewModel.transition(to: .recording(react: lockedReact))
                            }

                            AnalyticsService.shared.track(
                                ReactAnalyticsEvents.reactionCaptureStarted,
                                properties: [
                                    "share_id": react.id.uuidString,
                                    "receiver_id": User.sample.id.uuidString,
                                    "attempt_index": "1",
                                    "camera_permission_state": "granted",
                                ]
                            )
                        },
                        onCaptureInterrupted: {
                            self.onCaptureAbandoned(react, "recording_background")
                            self.flowViewModel.fail(
                                react,
                                reason: .recordingFailed(description: "Capture interrupted by app background")
                            )
                            self.flowViewModel.resetToLocked(react)
                        },
                        onReactionCaptured: { url in
                            let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber)?.intValue ?? 0
                            self.flowViewModel.transition(to: .preview(react: react, videoURL: url))
                            AnalyticsService.shared.track(
                                ReactAnalyticsEvents.reactionCaptureCompleted,
                                properties: [
                                    "share_id": react.id.uuidString,
                                    "receiver_id": User.sample.id.uuidString,
                                    "reaction_duration_sec": "unknown",
                                    "retake_count": "0",
                                    "file_size_bucket": ReactAnalyticsEvents.payloadSizeBucket(bytes: fileSize),
                                ]
                            )
                            self.capturedVideoURL = url
                        }
                    )
                case .preview(let react, _):
                    ConfirmView(
                        react: react,
                        onSend: {
                            guard let capturedVideoURL else { return }
                            self.flowViewModel.transition(to: .uploading(react: react))
                            self.onReactionSent(react, capturedVideoURL)
                            self.flowViewModel.transition(to: .success(react: react, videoURL: capturedVideoURL))
                        },
                        onCancel: {
                            self.onCaptureAbandoned(react, "preview")
                            self.flowViewModel.transition(to: .locked(react: react))
                        }
                    )
                case .uploading:
                    ProgressView("Sending your reaction...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success:
                    ProgressView("Reaction sent")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .blocked, .expired, .error:
                    VStack(spacing: 16) {
                        Text("Unable to continue this reaction")
                            .font(.headline)
                        Button("Close") {
                            self.onClose()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let abandonStep: String
                        switch self.flowViewModel.state {
                        case .preview:
                            abandonStep = "preview"
                        case .recording, .countingDown:
                            abandonStep = "recording"
                        default:
                            abandonStep = "pre_recording"
                        }
                        self.onCaptureAbandoned(self.react, abandonStep)
                        self.onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.semibold))
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DemoAppRootView(dependencies: .live)
}

