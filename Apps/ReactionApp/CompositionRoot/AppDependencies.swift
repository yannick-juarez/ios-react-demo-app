//
//  AppDependencies.swift
//  React
//
//  Created by GitHub Copilot on 27/04/2026.
//

import Foundation
import CoreDomain
import CoreInfrastructure
import CorePersistence
import ReactionFeature

struct AppDependencies {

    let reactRepository: any ReactRepository
    let sendReactRequestUseCase: any SendReactRequestUseCaseProtocol
    let loadInboxUseCase: any LoadInboxUseCaseProtocol
    let recordReactionUseCase: any RecordReactionUseCaseProtocol
    let markReactAsUnlockedUseCase: any MarkReactAsUnlockedUseCaseProtocol
    let cameraPermissionClient: CameraPermissionClient

    init(
        repository: any ReactRepository,
        cameraPermissionClient: CameraPermissionClient = .live
    ) {
        self.reactRepository = repository
        self.sendReactRequestUseCase = SendReactRequestUseCase(repository: repository)
        self.loadInboxUseCase = LoadInboxUseCase(repository: repository)
        self.recordReactionUseCase = RecordReactionUseCase(repository: repository)
        self.markReactAsUnlockedUseCase = MarkReactAsUnlockedUseCase(repository: repository)
        self.cameraPermissionClient = cameraPermissionClient
    }

    static let live = AppDependencies(repository: LocalReactRepository())
}
