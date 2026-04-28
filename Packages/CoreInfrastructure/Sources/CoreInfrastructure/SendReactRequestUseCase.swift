//
//  SendReactRequestUseCase.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import CoreDomain

public struct SendReactRequestUseCase: SendReactRequestUseCaseProtocol {

    private let repository: any ReactRepository

    public init(repository: any ReactRepository) {
        self.repository = repository
    }

    public func execute(imageData: Data, hint: String, sender: User = .sample) throws -> React {
        try self.repository.saveIncomingReact(imageData: imageData, hint: hint, sender: sender)
    }
}
