//
//  ReactRequestSentView.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import SwiftUI

struct ReactRequestSentView: View {

    var body: some View {
        VStack {
            Image(systemName: "checkmark")
                .font(.title3.bold())
                .foregroundStyle(.green)
            Text("React request sent")
        }
    }
}

#Preview {
    ReactRequestSentView()
}
