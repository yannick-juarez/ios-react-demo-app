//
//  ReactionFlowViewModelTests.swift
//  CoreInfrastructureTests
//

import XCTest
@testable import CoreInfrastructure
@testable import CoreDomain

final class ReactionFlowViewModelTests: XCTestCase {

    let sampleReact = React(
        content: URL(string: "file:///tmp/image.jpg")!,
        hint: "Test",
        sender: .sample
    )

    // MARK: — State Management

    func test_initialState() {
        let viewModel = ReactionFlowViewModel()
        
        if case .loading = viewModel.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected initial state to be .loading")
        }
    }
    
    func test_validTransitionSucceeds() {
        let viewModel = ReactionFlowViewModel(initialState: .locked(react: sampleReact))
        
        viewModel.transition(to: .countingDown(react: sampleReact, remaining: 3))
        
        if case .countingDown = viewModel.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected state to be .countingDown after valid transition")
        }
    }
    
    func test_invalidTransitionIsIgnored() {
        let viewModel = ReactionFlowViewModel(initialState: .recording(react: sampleReact))
        
        // Invalid: cannot go from recording → locked
        viewModel.transition(to: .locked(react: sampleReact))
        
        if case .recording = viewModel.state {
            XCTAssertTrue(true, "State should remain unchanged after invalid transition")
        } else {
            XCTFail("Invalid transition should be silently rejected")
        }
    }
    
    func test_resetToLockedFromError() {
        let viewModel = ReactionFlowViewModel(initialState: .error(react: sampleReact, reason: .recordingFailed(description: "Test")))
        
        viewModel.resetToLocked(sampleReact)
        
        if case .locked = viewModel.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("resetToLocked should transition to locked state")
        }
    }
}
