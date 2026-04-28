//
//  ReactMainViewModel.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import Foundation

@MainActor
public final class ReactMainViewModel: ObservableObject {

	@Published var isRecording: Bool = false
	@Published private(set) var isRevealed: Bool = false
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
				self.isRevealed = self.isRecording
			}
		}
	}

	private func resetRevealCountdown() {
		self.countdownTask?.cancel()
		self.countdownTask = nil
		self.countdownValue = nil
		self.isRevealed = false
	}
}

