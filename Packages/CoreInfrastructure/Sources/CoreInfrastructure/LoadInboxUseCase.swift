//
//  LoadInboxUseCase.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import CoreDomain

public struct LoadInboxUseCase: LoadInboxUseCaseProtocol {

    private let repository: any ReactRepository

    public init(repository: any ReactRepository) {
        self.repository = repository
    }

    public func execute(sender: User = .sample) -> React? {
        self.repository.loadInboxReact(sender: sender)
    }

    public func loadLatest() -> React? {
        self.repository.loadLatestReact()
    }

    public func hasPendingDraft() -> Bool {
        self.repository.hasPendingInbox()
    }
}
