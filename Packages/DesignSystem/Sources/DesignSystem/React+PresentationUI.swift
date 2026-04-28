//
//  React+PresentationUI.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import SwiftUI
import CoreDomain

public extension React {

    func Content() -> some View {
        AsyncImage(url: self.content) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.secondary.opacity(0.2)
        }
        .clipped()
    }
}
