//
//  ReactCaptureButton.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import CoreDomain
import DesignSystem

public struct ReactCaptureButton: View {

    @Binding public var isPressed: Bool

    @State public var radius: CGFloat = 76
    @State public var strokeWidth: CGFloat = 3
    @State public var padding: CGFloat = 6

    public init(
        isPressed: Binding<Bool>,
        radius: CGFloat = 76,
        strokeWidth: CGFloat = 3,
        padding: CGFloat = 6
    ) {
        self._isPressed = isPressed
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.padding = padding
    }

    public var body: some View {
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

    ReactCaptureButton(isPressed: $pressed)
        .background(.black)
}
