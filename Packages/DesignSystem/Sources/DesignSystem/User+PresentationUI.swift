//
//  User+PresentationUI.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import SwiftUI
import CoreDomain

public extension User {

    func Avatar(radius: CGFloat = 36) -> some View {
        AsyncImage(url: self.profilePictureURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.secondary.opacity(0.2)
        }
        .frame(width: radius, height: radius)
        .clipShape(Circle())
    }
}
