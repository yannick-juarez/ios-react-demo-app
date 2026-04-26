//
//  React.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import Foundation

struct React: Codable {

    var id: UUID = UUID()

    var content: URL
    var hint: String
    var sender: User
}
