//
//  MarkReactAsUnlockedUseCase.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import CoreDomain

public struct MarkReactAsUnlockedUseCase: MarkReactAsUnlockedUseCaseProtocol {

    private let repository: any ReactRepository

    public init(repository: any ReactRepository) {
        self.repository = repository
    }

    public func execute(_ react: React) -> React {
        self.repository.markAsUnlocked(react)
    }
}
