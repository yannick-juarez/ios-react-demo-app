//
//  React+Samples.swift
//  React
//
//  Created by Yannick Juarez on 26/04/2026.
//

import Foundation

public extension React {

    static let sample = React(content: URL(string: "https://picsum.photos/400/640")!,
                              hint: "Guess what just happened?",
                              sender: .sample,
                              response: nil)
}
