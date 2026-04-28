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
        let reactFromDraft = AppGroupReactInboxStore.consumeLatestDraft().flatMap { incomingDraft in
            try? LocalDemoReactStore.save(
                sharedImage: incomingDraft.image,
                hint: incomingDraft.hint,
                sender: sender
            )
        }

        return reactFromDraft ?? LocalDemoReactStore.loadLatest()
    }

    public func loadLatestReact() -> React? {
        LocalDemoReactStore.loadLatest()
    }

    public func saveIncomingReact(sharedImage: UIImage, hint: String, sender: User) throws -> React {
        try LocalDemoReactStore.save(sharedImage: sharedImage, hint: hint, sender: sender)
    }

    public func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React {
        try LocalDemoReactStore.saveResponseVideo(sourceURL, for: react)
    }

    public func markAsUnlocked(_ react: React) -> React {
        react
    }
}
