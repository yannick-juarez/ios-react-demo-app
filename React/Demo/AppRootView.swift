//
//  AppRootView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import UIKit

struct AppRootView: View {

    enum AppState {
        case share
        case react(react: React)
        case confirm(react: React)
        case switchBackToSender
        case chatInbox
        case playback(videoURL: URL)
    }

    @State var state: AppState
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.scenePhase) private var scenePhase

    @State private var sharedImage: UIImage?
    @State private var capturedVideoURL: URL?
    @State private var currentReact: React = .sample

    init() {
        self._state = State(initialValue: .react(react: .sample))
    }

    var body: some View {
        Group {
            switch self.state {
            case .share:
                if let sharedImage {
                    RequestReactView(
                        sharedImage: sharedImage,
                        onCancel: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.state = .react(react: .sample)
                                self.sharedImage = nil
                            }
                        },
                        onContinue: { hint in
                            self.handleContinueFromShare(hint: hint)
                        }
                    )
                } else {
                    EmptyView()
                        .onAppear {
                            self.state = .react(react: .sample)
                        }
                }
            case .react(let react):
                MainReactView(
                    react: react,
                    onReactionCaptured: { url in
                        self.capturedVideoURL = url
                        self.currentReact = react
                        self.state = .confirm(react: react)
                    }
                )
            case .confirm(let react):
                ConfirmView(
                    react: react,
                    onSend: {
                        self.state = .switchBackToSender
                    },
                    onCancel: {
                        self.state = .react(react: react)
                    }
                )
            case .switchBackToSender:
                SwitchBackToSenderView(
                    onSwitchToPlayback: {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            if let url = self.capturedVideoURL {
                                self.state = .playback(videoURL: url)
                            } else {
                                self.state = .chatInbox
                            }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            case .chatInbox:
                ChatInboxView()
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            case .playback(let videoURL):
                ReactPlaybackView(react: self.currentReact, videoURL: videoURL)
            }
        }
        .environmentObject(self.notificationManager)
        .onAppear {
            self.consumeSharedImageIfNeeded()
        }
        .onChange(of: self.scenePhase) { newPhase in
            guard newPhase == .active else { return }
            self.consumeSharedImageIfNeeded()
        }
        .onChange(of: self.notificationManager.shouldOpenPlayback) { shouldOpen in
            guard shouldOpen else { return }
            self.openLatestReactFromStorageIfNeeded()
            self.notificationManager.consumeOpenPlaybackFlag()
        }
        .onOpenURL { incomingURL in
            guard incomingURL.scheme == SharedReactInbox.urlScheme else { return }
            self.consumeSharedImageIfNeeded()
        }
    }

    private func consumeSharedImageIfNeeded() {
        guard let incomingDraft = SharedReactInbox.consumeLatestDraft() else { return }

        let persistedReact = (try? LocalDemoReactStore.save(
            sharedImage: incomingDraft.image,
            hint: incomingDraft.hint,
            sender: .sample
        ))

        let fallbackReact = React(
            content: URL(string: "https://picsum.photos/400/640")!,
            hint: incomingDraft.hint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "No hint"
                : incomingDraft.hint,
            sender: .sample
        )

        withAnimation(.easeInOut(duration: 0.3)) {
            let reactToDisplay = persistedReact ?? fallbackReact
            self.currentReact = reactToDisplay
            self.state = .react(react: reactToDisplay)
        }
    }

    private func openLatestReactFromStorageIfNeeded() {
        self.consumeSharedImageIfNeeded()

        guard let latestReact = LocalDemoReactStore.loadLatest() else {
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentReact = latestReact
            self.state = .react(react: latestReact)
            self.sharedImage = nil
        }
    }

    private func handleContinueFromShare(hint: String) {
        guard let sharedImage else { return }

        let persistedReact = (try? LocalDemoReactStore.save(sharedImage: sharedImage, hint: hint))
            .flatMap { _ in LocalDemoReactStore.loadLatest() }

        withAnimation(.easeInOut(duration: 0.3)) {
            let reactToDisplay = persistedReact ?? React(
                content: URL(string: "https://picsum.photos/400/640")!,
                hint: hint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No hint" : hint,
                sender: .sample
            )

            self.currentReact = reactToDisplay
            self.state = .react(react: reactToDisplay)
            self.sharedImage = nil
        }
    }
}

#Preview {
    AppRootView()
}

