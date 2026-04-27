//
//  SwitchBackToSenderView.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI

struct SwitchBackToSenderView: View {

    let onSwitchToPlayback: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .font(.title.bold())
            Text("React sent")
                .font(.title3.bold())

            Spacer()

            Text("DEMO PURPOSES ONLY")
                .foregroundStyle(.orange)
            Button {
                self.onSwitchToPlayback()
            } label: {
                HStack {
                    Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                        .font(.title3)
                    Text("Switch back to sender")
                        .font(.headline)
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
    }
}

#Preview {
    SwitchBackToSenderView(onSwitchToPlayback: {})
        .preferredColorScheme(.dark)
}
