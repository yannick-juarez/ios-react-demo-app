//
//  MainReactView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

struct MainReactView: View {

    @State var react: React

    @State private var isRecording: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("BeReal")
            }

            VStack {
                SenderCapsule()
                ContentPreview(react: self.react)
                Text("Your reaction will be sent to \(self.react.sender.displayName)")
            }
            .padding()

            ZStack {
                if self.isRecording {
                    Circle()
                        .frame(width: 120, height: 120)
                        .padding(.top, -170)
                        .transition(.scale)
                }

                CaptureButton(isPressed: self.$isRecording)
            }
        }
        .animation(.easeIn(duration: 0.2), value: self.isRecording)
    }

    private func SenderCapsule() -> some View {
        HStack {
            self.react.sender.Avatar()
            Text(self.react.sender.displayName)
                .font(.headline)
        }
        .padding(4)
        .padding(.trailing)
        .background(
            Capsule()
                .fill(.secondary.opacity(0.2))
        )
    }
}

#Preview {
    MainReactView(react: .sample)
        .preferredColorScheme(.dark)
}
