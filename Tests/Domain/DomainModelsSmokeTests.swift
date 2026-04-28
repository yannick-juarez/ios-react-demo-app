import XCTest
@testable import React

final class DomainModelsSmokeTests: XCTestCase {

    func testReactSampleHasSenderAndHint() {
        let sample = React.sample

        XCTAssertFalse(sample.hint.isEmpty)
        XCTAssertFalse(sample.sender.displayName.isEmpty)
    }
}
