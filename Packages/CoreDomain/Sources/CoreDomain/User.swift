//
//  User.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import Foundation

public struct User: Codable, Sendable, Equatable {

    public var id: UUID
    public var username: String
    public var displayName: String
    public var profilePictureURL: URL?

    public init(id: UUID = UUID(), username: String, displayName: String, profilePictureURL: URL? = nil) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.profilePictureURL = profilePictureURL
    }
}
