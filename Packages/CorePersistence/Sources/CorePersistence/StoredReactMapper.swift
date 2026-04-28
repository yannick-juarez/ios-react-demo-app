//
//  StoredReactMapper.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import CoreDomain

enum StoredReactMapper {

    static func toDTO(_ react: React) -> StoredReactDTO {
        StoredReactDTO(
            version: 1,
            id: react.id,
            contentURL: react.content.absoluteString,
            hint: react.hint,
            sender: StoredUserDTO(
                id: react.sender.id,
                username: react.sender.username,
                displayName: react.sender.displayName,
                profilePictureURL: react.sender.profilePictureURL?.absoluteString
            ),
            responseURL: react.response?.absoluteString
        )
    }

    static func toDomain(_ dto: StoredReactDTO) -> React? {
        guard let contentURL = URL(string: dto.contentURL) else {
            return nil
        }

        let sender = User(
            id: dto.sender.id,
            username: dto.sender.username,
            displayName: dto.sender.displayName,
            profilePictureURL: dto.sender.profilePictureURL.flatMap(URL.init(string:))
        )

        return React(
            id: dto.id,
            content: contentURL,
            hint: dto.hint,
            sender: sender,
            response: dto.responseURL.flatMap(URL.init(string:))
        )
    }
}
