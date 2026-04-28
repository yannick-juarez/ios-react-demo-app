//
//  ConfirmView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import CoreDomain
import DesignSystem
import Foundation

public struct ConfirmView: View {

    public var react: React
    public let onSend: () -> Void
    public let onCancel: () -> Void

    @State private var countdownValue: Int = 3
    @State private var countdownTask: Task<Void, Never>? = nil
    @State private var showCancelConfirmation: Bool = false

    public init(react: React, onSend: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.react = react
        self.onSend = onSend
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack {
            Text("\(self.countdownValue)")
                .font(.system(size: 96, weight: .medium))

            self.react.sender.Avatar(radius: 72)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 2)
                }

            Rectangle()
                .frame(width: 2, height: CGFloat(50 * self.countdownValue))

            ZStack(alignment: .topLeading) {
                self.react.Content()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 2)
                    }
            }

            Spacer()

            Button {
                self.sendReaction()
            } label: {
                HStack {
                    Spacer()
                    Text(
                        String(
                            localized: "camera.confirm.send_now",
                            defaultValue: "Send React Now",
                            bundle: .module
                        )
                    )
                    Spacer()
                }
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            Button {
                self.showCancelConfirmation = true
            } label: {
                Text(
                    String(
                        localized: "camera.common.cancel",
                        defaultValue: "Cancel",
                        bundle: .module
                    )
                )
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .foregroundStyle(.secondary)
        }
        .onAppear {
            self.startCountdown()
        }
        .onDisappear {
            self.cancelCountdown()
        }
        .animation(.easeInOut, value: self.countdownValue)
        .alert(
            String(
                localized: "camera.confirm.cancel.title",
                defaultValue: "Are you sure?",
                bundle: .module
            ),
            isPresented: self.$showCancelConfirmation
        ) {
            Button(
                String(
                    localized: "camera.confirm.cancel_recording",
                    defaultValue: "Cancel recording",
                    bundle: .module
                ),
                role: .destructive
            ) {
                self.cancelCountdown()
                self.onCancel()
            }
            Button(
                String(
                    localized: "camera.confirm.keep_recording",
                    defaultValue: "Keep recording",
                    bundle: .module
                ),
                role: .cancel
            ) {
                self.startCountdown()
            }
        } message: {
            Text(
                String(
                    localized: "camera.confirm.cancel.message",
                    defaultValue: "This will discard your recording.",
                    bundle: .module
                )
            )
        }
    }

    private func startCountdown() {
        self.cancelCountdown()

        self.countdownTask = Task {
            for value in stride(from: 4, through: 1, by: -1) {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.countdownValue = value - 1
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }

            if Task.isCancelled { return }

            await MainActor.run {
                self.sendReaction()
            }
        }
    }

    private func cancelCountdown() {
        self.countdownTask?.cancel()
        self.countdownTask = nil
    }

    private func sendReaction() {
        self.cancelCountdown()
        self.onSend()
    }
}

#Preview {
    ConfirmView(
        react: .sample,
        onSend: {},
        onCancel: {}
    )
    .preferredColorScheme(.dark)
}
