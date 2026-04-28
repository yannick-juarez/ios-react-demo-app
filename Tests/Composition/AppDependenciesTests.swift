import XCTest
import UIKit
@testable import React

final class AppDependenciesTests: XCTestCase {

    func testDependenciesExposeProtocolPorts() {
        let repo = ReactRepositoryMock()
        let deps = AppDependencies(repository: repo, cameraPermissionClient: .live)

        XCTAssertNotNil(deps.loadInboxUseCase as Any)
        XCTAssertNotNil(deps.recordReactionUseCase as Any)
        XCTAssertNotNil(deps.sendReactRequestUseCase as Any)
        XCTAssertNotNil(deps.markReactAsUnlockedUseCase as Any)
    }
}

private final class ReactRepositoryMock: ReactRepository {
    func hasPendingInbox() -> Bool { false }
    func loadInboxReact(sender: User) -> React? { nil }
    func loadLatestReact() -> React? { nil }
    func saveIncomingReact(sharedImage: UIImage, hint: String, sender: User) throws -> React { .sample }
    func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React { react }
    func markAsUnlocked(_ react: React) -> React { react }
}
