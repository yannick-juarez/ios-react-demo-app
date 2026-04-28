//
//  ReactRepository.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation

public protocol ReactRepository {
    func hasPendingInbox() -> Bool
    func loadInboxReact(sender: User) -> React?
    func loadLatestReact() -> React?
    /// Accept image data (not UIImage) to keep domain framework-free.
    func saveIncomingReact(imageData: Data, hint: String, sender: User) throws -> React
    func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React
    func markAsUnlocked(_ react: React) -> React
}
