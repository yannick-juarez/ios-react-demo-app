//
//  React+UI.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import SwiftUI
import NukeUI

extension React {

    @ViewBuilder
    func Content() -> some View {
        LazyImage(url: self.content)
    }
}
