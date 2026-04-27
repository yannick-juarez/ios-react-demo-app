//
//  RequestReactView.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import SwiftUI
import UIKit

struct RequestReactView: View {
    let sharedImage: UIImage
    let onCancel: () -> Void
    let onContinue: () -> Void

    var cornerRadius: CGFloat = 20

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Nouvelle photo recue")
                    .font(.title2.bold())
                Text("Cette image vient du menu Partager")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Image(uiImage: self.sharedImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 360, maxHeight: 520)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(.white.opacity(0.4), lineWidth: 1)
                }
                .padding()

            HStack(spacing: 12) {
                Button("Annuler") {
                    self.onCancel()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.thinMaterial)
                .clipShape(Capsule())

                Button("Continuer") {
                    self.onContinue()
                }
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.white)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    RequestReactView(
        sharedImage: UIImage(systemName: "photo")!,
        onCancel: {},
        onContinue: {}
    )
    .preferredColorScheme(.dark)
}
