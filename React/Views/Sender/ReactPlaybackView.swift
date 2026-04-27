//
//  ReactPlaybackView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

struct ReactPlaybackView: View {

    @State var react: React = .sample

    @State private var replyText: String = ""

    var cornerRadius: CGFloat = 20
    var strokeWidth: CGFloat = 3
    var previewRadius: CGFloat = 120

    var body: some View {
        VStack(spacing: 12) {
            SenderCapsule(user: .sample)
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .fill(.clear)
                    .background {
                        self.react.Content()
                            .scaledToFill()
                    }
                    .clipped()
                    .overlay {
                        RoundedRectangle(cornerRadius: self.cornerRadius)
                            .stroke(lineWidth: self.strokeWidth)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))

                // To replace by video playback
                react.sender.Avatar(radius: self.previewRadius)
                    .overlay {
                        Circle()
                            .stroke(.primary, lineWidth: 2)
                    }
                    .padding(.top, -self.previewRadius * 0.5)
            }
            .padding(.horizontal)
            .padding(.top, self.previewRadius * 0.5)

            HStack {
                TextField("Add a reply...", text: self.$replyText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Image(systemName: "camera.fill")
                    .font(.title3)
                    .padding(10)
                    .foregroundStyle(.black)
                    .background(.white)
                    .clipShape(Circle())
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ReactPlaybackView()
        .preferredColorScheme(.dark)
}
