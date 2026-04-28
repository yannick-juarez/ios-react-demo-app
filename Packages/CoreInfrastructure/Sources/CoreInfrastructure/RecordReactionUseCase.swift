//
//  RecordReactionUseCase.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import CoreDomain

public struct RecordReactionUseCase: RecordReactionUseCaseProtocol {

    private let repository: any ReactRepository

    public init(repository: any ReactRepository) {
        self.repository = repository
    }

    public func execute(videoURL: URL, for react: React) throws -> React {
        try self.repository.saveResponseVideo(videoURL, for: react)
    }
}
