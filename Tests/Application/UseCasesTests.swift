import XCTest
import UIKit
@testable import React

final class UseCasesTests: XCTestCase {

    func testLoadInboxUseCaseDelegatesToRepository() {
        let repo = ReactRepositoryMock()
        let expected = React.sample
        repo.loadInboxResult = expected

        let sut = LoadInboxUseCase(repository: repo)

        let result = sut.execute(sender: .sample)

        XCTAssertEqual(result?.id, expected.id)
        XCTAssertEqual(repo.loadInboxCallCount, 1)
    }

    func testRecordReactionUseCaseDelegatesToRepository() throws {
        let repo = ReactRepositoryMock()
        var expected = React.sample
        expected.response = URL(fileURLWithPath: "/tmp/response.mov")
        repo.recordReactionResult = expected

        let sut = RecordReactionUseCase(repository: repo)
        let result = try sut.execute(videoURL: URL(fileURLWithPath: "/tmp/input.mov"), for: .sample)

        XCTAssertEqual(result.response, expected.response)
        XCTAssertEqual(repo.recordReactionCallCount, 1)
    }
}

private final class ReactRepositoryMock: ReactRepository {
    var loadInboxResult: React?
    var recordReactionResult: React = .sample

    var loadInboxCallCount: Int = 0
    var recordReactionCallCount: Int = 0

    func hasPendingInbox() -> Bool { false }

    func loadInboxReact(sender: User) -> React? {
        self.loadInboxCallCount += 1
        return self.loadInboxResult
    }

    func loadLatestReact() -> React? { nil }

    func saveIncomingReact(sharedImage: UIImage, hint: String, sender: User) throws -> React {
        .sample
    }

    func saveResponseVideo(_ sourceURL: URL, for react: React) throws -> React {
        self.recordReactionCallCount += 1
        return self.recordReactionResult
    }

    func markAsUnlocked(_ react: React) -> React { react }
}
