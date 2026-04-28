//
//  PermissionsView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

public struct ReactPermissionsView: View {

    @EnvironmentObject private var permissionsManager: PermissionsManager

    public var body: some View {
        VStack(spacing: 12) {
            Text(self.permissionsManager.protectionMessage)
                .font(.headline)

            if let actionTitle = self.permissionsManager.actionTitle {
                Button(actionTitle) {
                    self.permissionsManager.handlePrimaryAction()
                }
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    ReactPermissionsView()
        .environmentObject(PermissionsManager())
        .preferredColorScheme(.dark)
}
