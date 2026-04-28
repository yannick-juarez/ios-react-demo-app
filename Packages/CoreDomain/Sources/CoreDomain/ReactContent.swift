//
//  ReactContent.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation

public struct ReactContent: Codable, Sendable {
    public var mediaURL: URL
    public init(mediaURL: URL) { self.mediaURL = mediaURL }
}
