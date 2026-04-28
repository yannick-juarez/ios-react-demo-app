//
//  ReactPlaybackView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import AVFoundation
import CoreDomain
import DesignSystem

private final class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var player: AVPlayer?
    private var observedItem: AVPlayerItem?
    private var onFinished: (() -> Void)?

    deinit {
        if let observedItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: observedItem
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }

    func configure(url: URL, onFinished: @escaping () -> Void) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player
        self.onFinished = onFinished

        if let observedItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: observedItem
            )
        }

        self.observedItem = item
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )

        self.playerLayer.player = player
        self.playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer.transform = CATransform3DMakeScale(-1, 1, 1)
        if self.playerLayer.superlayer == nil {
            self.layer.addSublayer(self.playerLayer)
        }

        player.play()
    }

    @objc
    private func playerDidFinish(_ notification: Notification) {
        self.onFinished?()
    }
}

private struct VideoLoopPlayerView: UIViewRepresentable {
    let url: URL
    let onFinished: () -> Void

    func makeUIView(context: Context) -> LoopingPlayerUIView {
        let view = LoopingPlayerUIView()
        view.backgroundColor = .black
        view.configure(url: self.url, onFinished: self.onFinished)
        return view
    }

    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {
        uiView.configure(url: self.url, onFinished: self.onFinished)
    }
}

public struct ReactPlaybackView: View {

    @State var react: React
    let videoURL: URL
    let onFinished: () -> Void

    @State private var replyText: String = ""

    var cornerRadius: CGFloat = 20
    var strokeWidth: CGFloat = 3
    var previewRadius: CGFloat = 120

    public init(
        react: React,
        videoURL: URL,
        onFinished: @escaping () -> Void,
        cornerRadius: CGFloat = 20,
        strokeWidth: CGFloat = 3,
        previewRadius: CGFloat = 120
    ) {
        self._react = State(initialValue: react)
        self.videoURL = videoURL
        self.onFinished = onFinished
        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
        self.previewRadius = previewRadius
    }

    public var body: some View {
        VStack(spacing: 12) {
            ReactSenderCapsule2(user: .sample)
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

                VideoLoopPlayerView(url: self.videoURL, onFinished: self.onFinished)
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
    ReactPlaybackView(react: .sample, videoURL: URL(string: "file:///dev/null")!, onFinished: {})
        .preferredColorScheme(.dark)
}
