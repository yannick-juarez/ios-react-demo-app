//
//  Reaction.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation

public struct Reaction: Codable, Sendable {
    public var id: UUID
    public var reactId: UUID
    public var videoURL: URL
    public var createdAt: Date
    public init(id: UUID = UUID(), reactId: UUID, videoURL: URL, createdAt: Date = Date()) {
        self.id = id
        self.reactId = reactId
        self.videoURL = videoURL
        self.createdAt = createdAt
    }
}
