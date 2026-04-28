//
//  ReactionFlowStateTests.swift
//  CoreDomainTests
//
//  Tests for state machine validation. Minimal but credible.

import XCTest
@testable import CoreDomain

final class ReactionFlowStateTests: XCTestCase {

    let sampleReact = React(
        content: URL(string: "file:///tmp/image.jpg")!,
        hint: "Test",
        sender: .sample
    )

    // MARK: — Valid Transitions
    
    func test_validTransition_loadingToLocked() {
        let state1 = ReactionFlowState.loading(progress: 0.5)
        let state2 = ReactionFlowState.locked(react: sampleReact)
        
        XCTAssertTrue(state1.canTransition(to: state2))
    }
    
    func test_validTransition_lockedToCountdown() {
        let state1 = ReactionFlowState.locked(react: sampleReact)
        let state2 = ReactionFlowState.countingDown(react: sampleReact, remaining: 3)
        
        XCTAssertTrue(state1.canTransition(to: state2))
    }
    
    func test_validTransition_recordingToPreview() {
        let state1 = ReactionFlowState.recording(react: sampleReact)
        let state2 = ReactionFlowState.preview(react: sampleReact, videoURL: URL(string: "file:///tmp/video.mov")!)
        
        XCTAssertTrue(state1.canTransition(to: state2))
    }
    
    // MARK: — Invalid Transitions
    
    func test_invalidTransition_recordingToLocked() {
        let state1 = ReactionFlowState.recording(react: sampleReact)
        let state2 = ReactionFlowState.locked(react: sampleReact)
        
        XCTAssertFalse(state1.canTransition(to: state2), "Cannot go back from recording to locked")
    }
    
    func test_invalidTransition_successToRecording() {
        let state1 = ReactionFlowState.success(react: sampleReact, videoURL: URL(string: "file:///tmp/video.mov")!)
        let state2 = ReactionFlowState.recording(react: sampleReact)
        
        XCTAssertFalse(state1.canTransition(to: state2), "Cannot restart recording after success")
    }
    
    // MARK: — Error Recovery
    
    func test_validTransition_errorToLockedRetry() {
        let state1 = ReactionFlowState.error(react: sampleReact, reason: .recordingFailed(description: "Test error"))
        let state2 = ReactionFlowState.locked(react: sampleReact)
        
        XCTAssertTrue(state1.canTransition(to: state2), "Should allow retry from error")
    }
    
    func test_debugLabel() {
        XCTAssertEqual(ReactionFlowState.loading(progress: 0).debugLabel, "loading")
        XCTAssertEqual(ReactionFlowState.locked(react: sampleReact).debugLabel, "locked")
        XCTAssertEqual(ReactionFlowState.success(react: sampleReact, videoURL: URL(string: "file:///tmp/video.mov")!).debugLabel, "success")
    }
}
