//
//  CaptureButton.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

struct CaptureButton: View {

    @Binding var isPressed: Bool

    @State var radius: CGFloat = 76
    @State var strokeWidth: CGFloat = 3
    @State var padding: CGFloat = 6

    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.white)

            if self.isPressed {
                Circle()
                    .fill(.black)
                    .padding(self.padding - self.strokeWidth)
            } else {
                Circle()
                    .stroke(.black, lineWidth: self.strokeWidth)
                    .padding(self.padding)
            }
        }
        .frame(width: self.radius, height: self.radius)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !self.isPressed else { return }
                    self.isPressed = true
                }
                .onEnded { _ in
                    guard self.isPressed else { return }
                    self.isPressed = false
                }
        )
        .animation(.default, value: self.isPressed)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var pressed: Bool = false

    CaptureButton(isPressed: $pressed)
        .background(.black)
}
