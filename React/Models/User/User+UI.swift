//
//  User+UI.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import NukeUI

extension User {

    @ViewBuilder
    func Avatar(radius: CGFloat = 36) -> some View {
        LazyImage(url: self.profilePictureURL)
            .scaledToFill()
            .frame(width: radius, height: radius)
            .clipShape(Circle())
    }
}
