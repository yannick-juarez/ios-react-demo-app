//
//  MainReactView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import Combine
import CoreDomain
import CoreInfrastructure
import DesignSystem
import CameraFeature

public struct ReactMainView: View {

    @State var react: React
    @StateObject private var permissionsManager: PermissionsManager
    @StateObject private var viewModel: ReactMainViewModel
    @Environment(\.scenePhase) private var scenePhase

    let onReactionCaptured: (URL) -> Void

    public init(
        react: React,
        permissionClient: CameraPermissionClient = .live,
        onReactionCaptured: @escaping (URL) -> Void
    ) {
        self._react = State(initialValue: react)
        self.onReactionCaptured = onReactionCaptured
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
                Text("Your reaction will be sent to \(self.react.sender.displayName)")
                    .font(.subheadline)
            }
            .padding()

            ZStack {
                FrontCameraPreview(
                    radius: 120,
                    isRecording: self.viewModel.isRecording,
                    onVideoReady: { url in
                        self.onReactionCaptured(url)
                    }
                )
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
        }
        .onChange(of: self.scenePhase) { newPhase in
            guard newPhase == .active else { return }
            self.permissionsManager.refreshStatuses()
        }
        .onChange(of: self.viewModel.isRecording) { newValue in
            self.viewModel.handleRecordingChanged(newValue)
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
