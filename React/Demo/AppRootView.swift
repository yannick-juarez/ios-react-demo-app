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
        case playback
    }

    @State var state: AppState
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.scenePhase) private var scenePhase

    @State private var sharedImage: UIImage?

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
                        onContinue: {
                            // The next step will create a React from this image.
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
                    onReactionCaptured: {
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
                            self.state = .chatInbox
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
            case .playback:
                EmptyView()
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
        .onOpenURL { incomingURL in
            guard incomingURL.scheme == SharedReactInbox.urlScheme else { return }
            self.consumeSharedImageIfNeeded()
        }
    }

    private func consumeSharedImageIfNeeded() {
        guard let image = SharedReactInbox.consumeLatestImage() else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            self.sharedImage = image
            self.state = .share
        }
    }
}

#Preview {
    AppRootView()
}

