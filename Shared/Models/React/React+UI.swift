//
//  React+UI.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

extension React {

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

#Preview {
    React.sample.Content()
        .border(.blue, width: 2)
        .background(Rectangle().fill(.red).ignoresSafeArea())
}
