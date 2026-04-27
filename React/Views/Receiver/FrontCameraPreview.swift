//
//  FrontCameraPreview.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import SwiftUI
import AVFoundation
import Combine

final class FrontCameraSession: NSObject, ObservableObject {

    let session = AVCaptureSession()
    private var isConfigured = false
    private let movieOutput = AVCaptureMovieFileOutput()
    private var onRecordingFinished: ((URL) -> Void)?

    func configure() {
        guard !self.isConfigured else { return }
        self.isConfigured = true

        self.session.sessionPreset = .high

        guard
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let cameraInput = try? AVCaptureDeviceInput(device: camera),
            self.session.canAddInput(cameraInput)
        else { return }

        self.session.addInput(cameraInput)

        if let mic = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device: mic),
           self.session.canAddInput(micInput) {
            self.session.addInput(micInput)
        }

        if self.session.canAddOutput(self.movieOutput) {
            self.session.addOutput(self.movieOutput)
        }
    }

    func start() {
        guard !self.session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stop() {
        guard self.session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }

    func startRecording() {
        guard !self.movieOutput.isRecording else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        self.movieOutput.startRecording(to: url, recordingDelegate: self)
    }

    func stopRecording(completion: @escaping (URL) -> Void) {
        guard self.movieOutput.isRecording else { return }
        self.onRecordingFinished = completion
        self.movieOutput.stopRecording()
    }
}

extension FrontCameraSession: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        guard error == nil else { return }
        DispatchQueue.main.async {
            self.onRecordingFinished?(outputFileURL)
            self.onRecordingFinished = nil
        }
    }
}

private final class CameraPreviewUIView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.previewLayer?.frame = self.bounds
    }
}

private struct CameraLayerView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer = previewLayer
        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

struct FrontCameraPreview: View {

    let radius: CGFloat
    let isRecording: Bool
    let onVideoReady: (URL) -> Void

    @StateObject private var cameraSession = FrontCameraSession()

    var body: some View {
        CameraLayerView(session: self.cameraSession.session)
            .frame(width: self.radius * 2, height: self.radius * 2)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(.white, lineWidth: 2)
            }
            .onAppear {
                self.cameraSession.configure()
                self.cameraSession.start()
            }
            .onDisappear {
                self.cameraSession.stop()
            }
            .onChange(of: self.isRecording) { newValue in
                if newValue {
                    self.cameraSession.startRecording()
                } else {
                    self.cameraSession.stopRecording { url in
                        self.onVideoReady(url)
                    }
                }
            }
    }
}
