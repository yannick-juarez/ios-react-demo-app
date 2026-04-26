//
//  ContentPreview.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

struct ContentPreview: View {

    @State var isBlurred: Bool = true

    @State private var cornerRadius: CGFloat = 32
    @State private var placeholderColor: Color = .secondary
    @State private var strokeWidth: CGFloat = 3

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .fill(.secondary)
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .stroke(lineWidth: self.strokeWidth)
        }
    }
}

#Preview {
    ContentPreview()
}
