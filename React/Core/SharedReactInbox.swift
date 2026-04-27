//
//  SharedReactInbox.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import Foundation
import UIKit

struct SharedReactInbox {
    static let appGroupIdentifier = "group.com.yannickjuarez.React"
    static let urlScheme = "reactdemo"

    private static let inboxFolderName = "SharedReactInbox"
    private static let manifestFileName = "latest.json"

    struct Manifest: Codable {
        let imageFileName: String
        let hint: String
        let createdAt: Date
    }

    struct IncomingReactDraft {
        let image: UIImage
        let hint: String
    }

    static func consumeLatestDraft() -> IncomingReactDraft? {
        guard let inboxURL = inboxDirectoryURL(createIfNeeded: false) else {
            return nil
        }

        let manifestURL = inboxURL.appendingPathComponent(manifestFileName)
        guard let manifestData = try? Data(contentsOf: manifestURL),
              let manifest = try? JSONDecoder().decode(Manifest.self, from: manifestData)
        else {
            return nil
        }

        let imageURL = inboxURL.appendingPathComponent(manifest.imageFileName)
        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData)
        else {
            return nil
        }

        // Consume once to avoid re-opening the same media every time the app resumes.
        try? FileManager.default.removeItem(at: manifestURL)
        try? FileManager.default.removeItem(at: imageURL)

        return IncomingReactDraft(image: image, hint: manifest.hint)
    }

    static func consumeLatestImage() -> UIImage? {
        consumeLatestDraft()?.image
    }

    static func saveIncomingImageData(
        _ data: Data,
        hint: String = "No hint",
        preferredFileExtension: String = "jpg"
    ) throws {
        guard let inboxURL = inboxDirectoryURL(createIfNeeded: true) else {
            throw SharedInboxError.appGroupNotFound
        }

        let fileName = "incoming-\(UUID().uuidString).\(preferredFileExtension)"
        let imageURL = inboxURL.appendingPathComponent(fileName)
        try data.write(to: imageURL, options: .atomic)

        let normalizedHint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        let manifest = Manifest(
            imageFileName: fileName,
            hint: normalizedHint.isEmpty ? "No hint" : normalizedHint,
            createdAt: Date()
        )
        let manifestData = try JSONEncoder().encode(manifest)
        let manifestURL = inboxURL.appendingPathComponent(manifestFileName)
        try manifestData.write(to: manifestURL, options: .atomic)
    }

    private static func inboxDirectoryURL(createIfNeeded: Bool) -> URL? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            return nil
        }

        let inboxURL = containerURL.appendingPathComponent(inboxFolderName, isDirectory: true)
        if createIfNeeded {
            try? FileManager.default.createDirectory(at: inboxURL, withIntermediateDirectories: true)
        }
        return inboxURL
    }

    enum SharedInboxError: Error {
        case appGroupNotFound
    }
}
