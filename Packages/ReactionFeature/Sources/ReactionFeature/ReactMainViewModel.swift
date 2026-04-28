//
//  ReactMainViewModel.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import Foundation

public struct ReactMainPreviewState {
	public var isRecording: Bool
	public var isRevealed: Bool
	public var canStartRecording: Bool
	public var countdownValue: Int?

	public init(
		isRecording: Bool,
		isRevealed: Bool,
		canStartRecording: Bool,
		countdownValue: Int?
	) {
		self.isRecording = isRecording
		self.isRevealed = isRevealed
		self.canStartRecording = canStartRecording
		self.countdownValue = countdownValue
	}
}

@MainActor
public final class ReactMainViewModel: ObservableObject {

	@Published var isRecording: Bool = false
	@Published private(set) var isRevealed: Bool = false
	@Published private(set) var canStartRecording: Bool = false
	@Published private(set) var countdownValue: Int? = nil

	private var countdownTask: Task<Void, Never>? = nil

	func handleRecordingChanged(_ isRecording: Bool) {
		if isRecording {
			self.startRevealCountdown()
		} else {
			self.resetRevealCountdown()
		}
	}

	func onDisappear() {
		self.resetRevealCountdown()
	}

	func applyPreviewState(_ state: ReactMainPreviewState) {
		self.countdownTask?.cancel()
		self.countdownTask = nil
		self.isRecording = state.isRecording
		self.isRevealed = state.isRevealed
		self.canStartRecording = state.canStartRecording
		self.countdownValue = state.countdownValue
	}

	private func startRevealCountdown() {
		self.resetRevealCountdown()

		self.countdownTask = Task {
			for value in stride(from: 3, through: 1, by: -1) {
				if Task.isCancelled { return }

				await MainActor.run {
					self.countdownValue = value
					self.isRevealed = false
				}

				try? await Task.sleep(nanoseconds: 1_000_000_000)
			}

			if Task.isCancelled { return }

			await MainActor.run {
				self.countdownValue = nil
				self.canStartRecording = self.isRecording
				self.isRevealed = self.isRecording
			}
		}
	}

	private func resetRevealCountdown() {
		self.countdownTask?.cancel()
		self.countdownTask = nil
		self.countdownValue = nil
		self.canStartRecording = false
		self.isRevealed = false
	}
}

