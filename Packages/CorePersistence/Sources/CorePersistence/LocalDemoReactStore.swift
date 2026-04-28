//
//  LocalDemoReactStore.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import UIKit
import CoreDomain

public struct LocalDemoReactStore {

    private static let directoryName = "LocalDemoReact"
    private static let imageFileName = "latest-shared-image.jpg"
    private static let reactFileName = "latest-react.json"
    private static let responseVideoFileName = "latest-response.mov"

    public static func save(
        imageData: Data,
        hint: String,
        sender: User = .sample,
        reactID: UUID = UUID()
    ) throws -> React {
        guard !imageData.isEmpty else {
            throw LocalDemoReactStoreError.invalidImage
        }

        let directoryURL = try storageDirectoryURL(createIfNeeded: true)
        let imageURL = directoryURL.appendingPathComponent(imageFileName)
        try imageData.write(to: imageURL, options: .atomic)

        let normalizedHint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        let react = React(
            id: reactID,
            content: imageURL,
            hint: normalizedHint.isEmpty ? "No hint" : normalizedHint,
            sender: sender,
            response: nil
        )

        try persist(react: react, in: directoryURL)

        return react
    }

    public static func loadLatest() -> React? {
        guard let directoryURL = try? storageDirectoryURL(createIfNeeded: false) else {
            return nil
        }

        let reactURL = directoryURL.appendingPathComponent(reactFileName)
        guard let data = try? Data(contentsOf: reactURL) else {
            return nil
        }

        guard let dto = try? JSONDecoder().decode(StoredReactDTO.self, from: data) else {
            return nil
        }

        return StoredReactMapper.toDomain(dto)
    }

    public static func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React {
        let directoryURL = try storageDirectoryURL(createIfNeeded: true)
        let responseURL = directoryURL.appendingPathComponent(responseVideoFileName)

        if FileManager.default.fileExists(atPath: responseURL.path) {
            try FileManager.default.removeItem(at: responseURL)
        }

        try FileManager.default.copyItem(at: sourceURL, to: responseURL)

        var updatedReact = react
        updatedReact.response = responseURL

        try persist(react: updatedReact, in: directoryURL)

        return updatedReact
    }

    private static func persist(react: React, in directoryURL: URL) throws {
        let dto = StoredReactMapper.toDTO(react)
        let data = try JSONEncoder().encode(dto)
        let reactURL = directoryURL.appendingPathComponent(reactFileName)
        try data.write(to: reactURL, options: .atomic)
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

    public enum LocalDemoReactStoreError: Error {
        case invalidImage
    }
}
