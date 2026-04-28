//
//  ReactionFlowViewModel.swift
//  CoreInfrastructure
//
//  Central state machine for the reaction flow. Coordinates all state transitions
//  with validation, logging, and safe transitions.

import Foundation
import CoreDomain
import Combine

@MainActor
public final class ReactionFlowViewModel: ObservableObject {
    
    @Published public private(set) var state: ReactionFlowState = .loading(progress: 0)
    
    private let logger = Logger(subsystem: "com.yannickjuarez.React.Flow", category: "StateMachine")
    
    public init(initialState: ReactionFlowState = .loading(progress: 0)) {
        self.state = initialState
    }
    
    /// Transition to a new state with validation. Logs warnings if transition is invalid.
    public func transition(to newState: ReactionFlowState) {
        guard state.canTransition(to: newState) else {
            logger.warning("Invalid transition: \(state.debugLabel) → \(newState.debugLabel)")
            return
        }
        
        logger.debug("Transition: \(state.debugLabel) → \(newState.debugLabel)")
        self.state = newState
    }
    
    /// Safely reset to locked state (retry scenario).
    public func resetToLocked(_ react: React) {
        transition(to: .locked(react: react))
    }
    
    /// Move to blocked state (permission denied).
    public func block(_ react: React, reason: ReactionFlowState.BlockReason) {
        transition(to: .blocked(react: react, reason: reason))
    }
    
    /// Transition to error state with reason.
    public func fail(_ react: React?, reason: ReactionFlowState.ErrorReason) {
        transition(to: .error(react: react, reason: reason))
    }
}

private let logger = Logger(subsystem: "com.yannickjuarez.React.Flow", category: "StateMachine")

// Simple logger shim (replace with OSLog if needed)
private struct Logger {
    let subsystem: String
    let category: String
    
    func warning(_ message: String) {
        print("[\(category)] ⚠️ \(message)")
    }
    
    func debug(_ message: String) {
        #if DEBUG
        print("[\(category)] 🔵 \(message)")
        #endif
    }
}
