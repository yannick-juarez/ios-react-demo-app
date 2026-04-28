//
//  AppGroupReactInboxStore.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import UIKit
import CoreDomain

public struct AppGroupReactInboxStore {
    public static let appGroupIdentifier = "group.com.yannickjuarez.React"
    public static let urlScheme = "reactdemo"

    private static let inboxFolderName = "SharedReactInbox"
    private static let manifestFileName = "latest.json"

    public struct Manifest: Codable {
        public let imageFileName: String
        public let hint: String
        public let createdAt: Date
    }

    public struct IncomingReactDraft {
        public let image: UIImage
        public let hint: String
    }

    public static func hasPendingDraft() -> Bool {
        guard let inboxURL = inboxDirectoryURL(createIfNeeded: false) else {
            return false
        }

        let manifestURL = inboxURL.appendingPathComponent(manifestFileName)
        return FileManager.default.fileExists(atPath: manifestURL.path)
    }

    public static func consumeLatestDraft() -> IncomingReactDraft? {
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

    public static func consumeLatestImage() -> UIImage? {
        consumeLatestDraft()?.image
    }

    public static func saveIncomingImageData(
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

    public enum SharedInboxError: Error {
        case appGroupNotFound
    }
}

// Compatibility bridge during migration.
public struct SharedReactInbox {
    public static let appGroupIdentifier = AppGroupReactInboxStore.appGroupIdentifier
    public static let urlScheme = AppGroupReactInboxStore.urlScheme

    public struct IncomingReactDraft {
        public let image: UIImage
        public let hint: String
    }

    public static func hasPendingDraft() -> Bool {
        AppGroupReactInboxStore.hasPendingDraft()
    }

    public static func consumeLatestDraft() -> IncomingReactDraft? {
        guard let draft = AppGroupReactInboxStore.consumeLatestDraft() else {
            return nil
        }
        return IncomingReactDraft(image: draft.image, hint: draft.hint)
    }

    public static func consumeLatestImage() -> UIImage? {
        AppGroupReactInboxStore.consumeLatestImage()
    }

    public static func saveIncomingImageData(
        _ data: Data,
        hint: String = "No hint",
        preferredFileExtension: String = "jpg"
    ) throws {
        try AppGroupReactInboxStore.saveIncomingImageData(
            data,
            hint: hint,
            preferredFileExtension: preferredFileExtension
        )
    }
}
