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
    func Avatar(radius: CGFloat = 44) -> some View {
        LazyImage(url: self.profilePictureURL)
            .frame(width: radius, height: radius)
            .clipShape(Circle())
    }
}
