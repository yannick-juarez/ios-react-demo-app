//
//  ChatInboxView.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import SwiftUI

struct ChatInboxView: View {

    @EnvironmentObject private var notificationManager: NotificationManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var isPlaybackPresented: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                Text("You are about to receive a React...")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                if self.notificationManager.isDenied {
                    Text("Notifications are disabled. Enable them in Settings to receive a React.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Open Settings") {
                        self.notificationManager.openSettingsForNotifications()
                    }
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())

                } else if !self.notificationManager.isAuthorized {
                    Text("Allow notifications so Yannick can send you a React.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Allow Notifications") {
                        self.notificationManager.requestAuthorization()
                    }
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())

                } else {
                    VStack(spacing: 8) {
                        Text("A notification will arrive in a few seconds.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text("Tap it to open your React.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Text("DEMO PURPOSES ONLY")
                    .font(.caption2)
                    .foregroundStyle(.orange)

                Button("Open React directly") {
                    self.isPlaybackPresented = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            Task { await self.notificationManager.refreshStatus() }
            if self.notificationManager.isAuthorized {
                self.notificationManager.scheduleReactNotification()
            }
        }
        .onChange(of: self.scenePhase) { newPhase in
            guard newPhase == .active else { return }
            Task { await self.notificationManager.refreshStatus() }
            if self.notificationManager.isAuthorized {
                self.notificationManager.scheduleReactNotification()
            }
        }
        .onChange(of: self.notificationManager.isAuthorized) { authorized in
            if authorized {
                self.notificationManager.scheduleReactNotification()
            }
        }
        .onChange(of: self.notificationManager.shouldOpenPlayback) { shouldOpen in
            if shouldOpen {
                self.isPlaybackPresented = true
            }
        }
        .sheet(isPresented: self.$isPlaybackPresented) {
            ReactPlaybackView(react: .sample, videoURL: URL(string: "file:///dev/null")!)
        }
    }
}

#Preview {
    ChatInboxView()
        .environmentObject(NotificationManager())
        .preferredColorScheme(.dark)
}
