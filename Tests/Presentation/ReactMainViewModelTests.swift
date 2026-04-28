import XCTest
@testable import React

@MainActor
final class ReactMainViewModelTests: XCTestCase {

    func testRecordingStopResetsRevealStateImmediately() {
        let sut = ReactMainViewModel()

        sut.isRecording = true
        sut.handleRecordingChanged(true)

        sut.isRecording = false
        sut.handleRecordingChanged(false)

        XCTAssertFalse(sut.isRevealed)
        XCTAssertNil(sut.countdownValue)
    }

    func testOnDisappearCancelsCountdownState() {
        let sut = ReactMainViewModel()

        sut.isRecording = true
        sut.handleRecordingChanged(true)
        sut.onDisappear()

        XCTAssertFalse(sut.isRevealed)
        XCTAssertNil(sut.countdownValue)
    }
}
