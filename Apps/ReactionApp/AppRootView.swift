//
//  AppRootView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import UIKit
import UserNotifications
import CoreDomain
import CoreInfrastructure
import CameraFeature
import ReactionFeature

struct AppRootView: View {

    @StateObject private var notificationManager = ReactNotificationScheduler()
    @Environment(\.scenePhase) private var scenePhase

    private let dependencies: AppDependencies

    @State private var currentReact: React?
    @State private var draftReactionVideoURL: URL?
    @State private var isIncomingReactPresented: Bool = false
    @State private var isPlaybackPresented: Bool = false
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined

    init(dependencies: AppDependencies = .live) {
        self.dependencies = dependencies
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
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
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
    }

    private func presentPlaybackIfNeeded() {
        guard let react = self.dependencies.loadInboxUseCase.loadLatest(), react.response != nil else { return }

        self.currentReact = react
        self.isIncomingReactPresented = false
        self.isPlaybackPresented = true
    }

    private func dismissIncomingReact() {
        self.isIncomingReactPresented = false
        self.draftReactionVideoURL = nil
        self.currentReact = nil
    }

    private func handleReactionSent(for react: React, videoURL: URL) {
        if let storedReact = try? self.dependencies.recordReactionUseCase.execute(videoURL: videoURL, for: react) {
            let unlockedReact = self.dependencies.markReactAsUnlockedUseCase.execute(storedReact)
            self.currentReact = unlockedReact
            self.notificationManager.schedulePlaybackNotification(senderName: unlockedReact.sender.displayName)
        }

        self.dismissIncomingReact()
    }
}

private struct IncomingReactFlowView: View {

    let react: React
    let cameraPermissionClient: CameraPermissionClient
    let onClose: () -> Void
    let onReactionSent: (React, URL) -> Void

    @State private var currentStep: Step = .capture
    @State private var capturedVideoURL: URL?

    enum Step {
        case capture
        case confirm
    }

    var body: some View {
        NavigationStack {
            Group {
                switch self.currentStep {
                case .capture:
                    ReactMainView(
                        react: self.react,
                        permissionClient: self.cameraPermissionClient,
                        onReactionCaptured: { url in
                            self.capturedVideoURL = url
                            self.currentStep = .confirm
                        }
                    )
                case .confirm:
                    ConfirmView(
                        react: self.react,
                        onSend: {
                            guard let capturedVideoURL else { return }
                            self.onReactionSent(self.react, capturedVideoURL)
                        },
                        onCancel: {
                            self.currentStep = .capture
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
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
    AppRootView()
}

