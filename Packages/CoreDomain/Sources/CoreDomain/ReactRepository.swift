//
//  ReactRepository.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import UIKit

public protocol ReactRepository {
    func hasPendingInbox() -> Bool
    func loadInboxReact(sender: User) -> React?
    func loadLatestReact() -> React?
    func saveIncomingReact(sharedImage: UIImage, hint: String, sender: User) throws -> React
    func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React
    func markAsUnlocked(_ react: React) -> React
}
