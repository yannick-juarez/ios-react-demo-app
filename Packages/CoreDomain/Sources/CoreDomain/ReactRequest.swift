//
//  ReactRequest.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation

public struct ReactRequest: Codable, Sendable {
    public var id: UUID
    public var content: ReactContent
    public var hint: String
    public var sender: User
    public var createdAt: Date
    public init(id: UUID = UUID(), content: ReactContent, hint: String, sender: User, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.hint = hint
        self.sender = sender
        self.createdAt = createdAt
    }
}
