//
//  MainReactView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import Combine

struct MainReactView: View {

    @State var react: React
    @StateObject private var permissionsManager = PermissionsManager()
    @Environment(\.scenePhase) private var scenePhase

    let onReactionCaptured: (URL) -> Void

    @State private var isRecording: Bool = false
    @State private var isRevealed: Bool = false
    @State private var wasRevealed: Bool = false
    @State private var countdownValue: Int? = nil
    @State private var countdownTask: Task<Void, Never>? = nil

    var body: some View {
        VStack {
            VStack {
                SenderCapsule(user: self.react.sender)
                ContentPreview(
                    react: self.react,
                    isBlurred: !self.isRevealed,
                    countdownValue: self.countdownValue
                )
                Text("Your reaction will be sent to \(self.react.sender.displayName)")
                    .font(.subheadline)
            }
            .padding()

            ZStack {
                if self.isRecording {
                    FrontCameraPreview(
                        radius: 120,
                        isRecording: self.isRecording,
                        onVideoReady: { url in
                            if self.wasRevealed {
                                self.onReactionCaptured(url)
                            }
                        }
                    )
                    .padding(.top, -170)
                    .transition(.scale)
                }

                CaptureButton(isPressed: self.$isRecording)
                    .disabled(!self.permissionsManager.areAllAuthorized)
                    .opacity(self.permissionsManager.areAllAuthorized ? 1 : 0.5)
            }
        }
        .environmentObject(self.permissionsManager)
        .animation(.easeIn(duration: 0.2), value: self.isRecording)
        .onAppear {
            self.permissionsManager.refreshStatuses()
        }
        .onChange(of: self.scenePhase) { newPhase in
            guard newPhase == .active else { return }
            self.permissionsManager.refreshStatuses()
        }
        .onChange(of: self.isRecording) { newValue in
            if newValue {
                self.wasRevealed = false
                self.startRevealCountdown()
            } else {
                self.wasRevealed = self.isRevealed
                self.resetRevealCountdown()
                // onReactionCaptured is called inside FrontCameraPreview.onVideoReady
            }
        }
        .onDisappear {
            self.resetRevealCountdown()
        }
    }

    private func startRevealCountdown() {
        self.resetRevealCountdown()

        self.countdownTask = Task {
            for value in stride(from: 3, through: 1, by: -1) {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.countdownValue = value
                    self.isRevealed = false
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }

            if Task.isCancelled { return }

            await MainActor.run {
                self.countdownValue = nil
                self.isRevealed = self.isRecording
            }
        }
    }

    private func resetRevealCountdown() {
        self.countdownTask?.cancel()
        self.countdownTask = nil
        self.countdownValue = nil
        self.isRevealed = false
    }
}

#Preview {
    MainReactView(react: .sample, onReactionCaptured: { _ in })
        .preferredColorScheme(.dark)
}
