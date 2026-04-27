//
//  UserCapsule.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

struct SenderCapsule: View {

    @State var user: User

    var body: some View {
        HStack {
            self.user.Avatar()

            VStack(alignment: .leading, spacing: 0) {
                Text(self.user.displayName)
                    .font(.headline)
                Text(self.user.username)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(4)
        .padding(.trailing)
        .background(
            Capsule()
                .fill(.secondary.opacity(0.2))
        )
    }
}

#Preview {
    SenderCapsule(user: .sample)
}
