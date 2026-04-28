//
//  ReactionFlowState.swift
//  React
//
//  Created by GitHub Copilot on 28/04/2026.
//  Domain-level state machine for the entire reaction loop.
//  Ensures all states from spec are explicitly modeled and transitions are clear.

import Foundation

/// Comprehensive state machine for the Share → React → Return flow.
/// Maps to spec section "Core states".
public enum ReactionFlowState: Equatable, Sendable {
    
    // MARK: — Sender Flow
    /// Share extension open, image being processed.
    case loading(progress: Double)
    
    // MARK: — Receiver Flow
    /// React locked; content hidden until reaction is recorded.
    case locked(react: React)
    
    /// Countdown before recording starts (3-2-1).
    case countingDown(react: React, remaining: Int)
    
    /// Recording video now.
    case recording(react: React)
    
    /// Review reaction before sending.
    case preview(react: React, videoURL: URL)
    
    /// Uploading reaction video.
    case uploading(react: React)
    
    // MARK: — Success
    /// Content unlocked; sender bundle queued for return.
    case success(react: React, videoURL: URL)
    
    // MARK: — Errors
    /// Camera/microphone permission required to proceed.
    case blocked(react: React, reason: BlockReason)
    
    /// Share expired (TTL exceeded).
    case expired(react: React)
    
    /// Error occurred; user can retry or abandon.
    case error(react: React?, reason: ErrorReason)
    
    // MARK: — Typed Errors
    public enum BlockReason: Equatable, Sendable {
        case cameraPermissionDenied
        case microphonePermissionDenied
        case bothPermissionsDenied
    }
    
    public enum ErrorReason: Equatable, Sendable {
        case networkFailure(description: String)
        case recordingFailed(description: String)
        case uploadFailed(description: String)
        case persistenceFailed(description: String)
        case unknown(description: String)
    }
    
    // MARK: — State Transitions (validation layer)
    
    /// Check if transition from current state to `next` is valid.
    public func canTransition(to next: ReactionFlowState) -> Bool {
        switch (self, next) {
        case (.loading, .locked): return true
        case (.loading, .error): return true
        
        case (.locked, .countingDown): return true
        case (.locked, .blocked): return true
        case (.locked, .expired): return true
        
        case (.countingDown, .recording): return true
        case (.countingDown, .blocked): return true
        
        case (.recording, .preview): return true
        case (.recording, .error): return true
        
        case (.preview, .uploading): return true
        case (.preview, .recording): return true // Retake
        case (.preview, .locked): return true
        case (.preview, .error): return true
        
        case (.uploading, .success): return true
        case (.uploading, .error): return true
        
        case (.blocked, .countingDown): return true // Permissions re-requested
        case (.blocked, .error): return true
        
        case (.error, .locked): return true // Retry from start
        case (.error, .countingDown): return true // Retry from locked
        
        default: return false
        }
    }
    
    /// Human-readable label for debugging & logging.
    public var debugLabel: String {
        switch self {
        case .loading: return "loading"
        case .locked: return "locked"
        case .countingDown: return "countingDown"
        case .recording: return "recording"
        case .preview: return "preview"
        case .uploading: return "uploading"
        case .success: return "success"
        case .blocked: return "blocked"
        case .expired: return "expired"
        case .error: return "error"
        }
    }
}
