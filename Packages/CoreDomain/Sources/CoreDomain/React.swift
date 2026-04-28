//
//  React.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import Foundation

public struct React: Codable, Sendable, Equatable {

    public var id: UUID
    public var content: URL
    public var hint: String
    public var sender: User
    public var response: URL?

    public init(id: UUID = UUID(), content: URL, hint: String, sender: User, response: URL? = nil) {
        self.id = id
        self.content = content
        self.hint = hint
        self.sender = sender
        self.response = response
    }
}
