//
//  ContentPreview.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import CoreDomain
import DesignSystem

public struct ContentPreview: View {

    @EnvironmentObject private var permissionsManager: PermissionsManager

    public let react: React
    public let isBlurred: Bool
    public let countdownValue: Int?

    @State private var cornerRadius: CGFloat = 32
    @State private var strokeWidth: CGFloat = 3

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .fill(.clear)
                .background {
                    self.react.Content()
                        .scaledToFill()
                }
                .clipped()

            if self.isBlurred {
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .fill(.thinMaterial)

                if let countdownValue = self.countdownValue {
                    VStack(spacing: 12) {
                        Text("\(countdownValue)")
                            .font(.system(size: 96, weight: .medium))

                        Text("Keep holding to unlock")
                            .font(.headline)
                    }
                } else {
                    VStack {
                        VStack {
                            Image(systemName: "link")
                                .font(.largeTitle)
                            Text("\(self.react.sender.displayName) has sent you a content to React")
                                .font(.title3.bold())
                        }
                        .padding()

                        Spacer()

                        VStack {
                            self.react.sender.Avatar(radius: 60)
                                .overlay {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                }
                            Text(self.react.hint)
                                .font(.title2.bold())
                        }

                        Spacer()
                        Spacer()

                        VStack {
                            if !self.permissionsManager.areAllAuthorized {
                                ReactPermissionsView()
                            } else {
                                Text("Hold the record button to unlock this content")
                                    .font(.title3.bold())
                            }
                        }
                        .multilineTextAlignment(.center)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.vertical)
                }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .stroke(lineWidth: self.strokeWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
    }
}

#Preview("Blurred") {
    ContentPreview(
        react: .sample,
        isBlurred: true,
        countdownValue: nil
    )
        .environmentObject(PermissionsManager())
        .padding()
        .background(Rectangle().fill(.red).ignoresSafeArea())
}

#Preview("Not blurred") {
    ContentPreview(
        react: .sample,
        isBlurred: false,
        countdownValue: nil
    )
        .environmentObject(PermissionsManager())
        .padding()
        .background(Rectangle().fill(.red).ignoresSafeArea())
}

#Preview("Countdown") {
    ContentPreview(
        react: .sample,
        isBlurred: true,
        countdownValue: 3
    )
        .environmentObject(PermissionsManager())
        .padding()
        .background(Rectangle().fill(.red).ignoresSafeArea())
}
