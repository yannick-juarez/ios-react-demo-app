//
//  LocalReactRepository.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import UIKit
import CoreDomain
import CorePersistence

public struct LocalReactRepository: ReactRepository {

    public init() {}

    public func hasPendingInbox() -> Bool {
        AppGroupReactInboxStore.hasPendingDraft()
    }

    public func loadInboxReact(sender: User) -> React? {
        let reactFromDraft = AppGroupReactInboxStore.consumeLatestDraft().flatMap { incomingDraft -> React? in
            let reactID = UUID(uuidString: incomingDraft.shareID) ?? UUID()
            // Convert UIImage → Data for domain-level API
            guard let imageData = incomingDraft.image.jpegData(compressionQuality: 0.92) else {
                return nil
            }
            return try? LocalDemoReactStore.save(
                imageData: imageData,
                hint: incomingDraft.hint,
                sender: sender,
                reactID: reactID
            )
        }

        return reactFromDraft ?? LocalDemoReactStore.loadLatest()
    }

    public func loadLatestReact() -> React? {
        LocalDemoReactStore.loadLatest()
    }

    public func saveIncomingReact(imageData: Data, hint: String, sender: User) throws -> React {
        try LocalDemoReactStore.save(imageData: imageData, hint: hint, sender: sender)
    }

    public func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React {
        try LocalDemoReactStore.saveResponseVideo(sourceURL, for: react)
    }

    public func markAsUnlocked(_ react: React) -> React {
        react
    }
}
