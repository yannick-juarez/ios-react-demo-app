//
//  ReactPlaybackView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import AVFoundation

private final class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }

    func configure(url: URL) {
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        self.player = queuePlayer

        self.playerLayer.player = queuePlayer
        self.playerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(self.playerLayer)

        queuePlayer.play()
    }
}

private struct VideoLoopPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> LoopingPlayerUIView {
        let view = LoopingPlayerUIView()
        view.backgroundColor = .black
        view.configure(url: self.url)
        return view
    }

    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}
}

struct ReactPlaybackView: View {

    @State var react: React
    let videoURL: URL

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

                VideoLoopPlayerView(url: self.videoURL)
                    .frame(width: self.previewRadius * 2, height: self.previewRadius * 2)
                    .clipShape(Circle())
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
    ReactPlaybackView(react: .sample, videoURL: URL(string: "file:///dev/null")!)
        .preferredColorScheme(.dark)
}
