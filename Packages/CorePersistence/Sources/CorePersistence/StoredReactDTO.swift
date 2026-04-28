//
//  StoredReactDTO.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation

struct StoredReactDTO: Codable {
    let version: Int
    let id: UUID
    let contentURL: String
    let hint: String
    let sender: StoredUserDTO
    let responseURL: String?
}

struct StoredUserDTO: Codable {
    let id: UUID
    let username: String
    let displayName: String
    let profilePictureURL: String?
}
