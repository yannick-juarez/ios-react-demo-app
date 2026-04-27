//
//  LocalDemoReactStore.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import UIKit

struct LocalDemoReactStore {

    private static let directoryName = "LocalDemoReact"
    private static let imageFileName = "latest-shared-image.jpg"
    private static let reactFileName = "latest-react.json"

    static func save(sharedImage: UIImage, hint: String, sender: User = .sample) throws -> React {
        guard let imageData = sharedImage.jpegData(compressionQuality: 0.92) else {
            throw LocalDemoReactStoreError.invalidImage
        }

        let directoryURL = try storageDirectoryURL(createIfNeeded: true)
        let imageURL = directoryURL.appendingPathComponent(imageFileName)
        try imageData.write(to: imageURL, options: .atomic)

        let normalizedHint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        let react = React(
            content: imageURL,
            hint: normalizedHint.isEmpty ? "No hint" : normalizedHint,
            sender: sender
        )

        let data = try JSONEncoder().encode(react)
        let reactURL = directoryURL.appendingPathComponent(reactFileName)
        try data.write(to: reactURL, options: .atomic)

        return react
    }

    static func loadLatest() -> React? {
        guard let directoryURL = try? storageDirectoryURL(createIfNeeded: false) else {
            return nil
        }

        let reactURL = directoryURL.appendingPathComponent(reactFileName)
        guard let data = try? Data(contentsOf: reactURL) else {
            return nil
        }

        return try? JSONDecoder().decode(React.self, from: data)
    }

    private static func storageDirectoryURL(createIfNeeded: Bool) throws -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)

        if createIfNeeded {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        return directoryURL
    }

    enum LocalDemoReactStoreError: Error {
        case invalidImage
    }
}
