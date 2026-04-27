//
//  User.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import Foundation

struct User: Codable {

    var id: UUID = UUID()

    var username: String
    var displayName: String
    var profilePictureURL: URL?
}
