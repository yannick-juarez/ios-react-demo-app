//
//  UseCaseProtocols.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import UIKit

public protocol SendReactRequestUseCaseProtocol {
    func execute(sharedImage: UIImage, hint: String, sender: User) throws -> React
}

public protocol LoadInboxUseCaseProtocol {
    func execute(sender: User) -> React?
    func loadLatest() -> React?
    func hasPendingDraft() -> Bool
}

public extension LoadInboxUseCaseProtocol {
    func execute() -> React? {
        self.execute(sender: .sample)
    }
}

public protocol RecordReactionUseCaseProtocol {
    func execute(videoURL: URL, for react: React) throws -> React
}

public protocol MarkReactAsUnlockedUseCaseProtocol {
    func execute(_ react: React) -> React
}
