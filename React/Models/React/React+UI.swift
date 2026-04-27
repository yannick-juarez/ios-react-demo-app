//
//  React+UI.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import NukeUI

extension React {

    func Content() -> some View {
        LazyImage(url: self.content) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.secondary.opacity(0.2)
            }
        }
        .clipped()
    }
}

#Preview {
    React.sample.Content()
        .border(.blue, width: 2)
        .background(Rectangle().fill(.red).ignoresSafeArea())
}
