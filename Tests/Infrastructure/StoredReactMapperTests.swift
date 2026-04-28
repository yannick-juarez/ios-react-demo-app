import XCTest
@testable import React

final class StoredReactMapperTests: XCTestCase {

    func testRoundTripPreservesMainFields() {
        var react = React.sample
        react.response = URL(fileURLWithPath: "/tmp/reaction.mov")

        let dto = StoredReactMapper.toDTO(react)
        let mappedBack = StoredReactMapper.toDomain(dto)

        XCTAssertEqual(mappedBack?.id, react.id)
        XCTAssertEqual(mappedBack?.content, react.content)
        XCTAssertEqual(mappedBack?.hint, react.hint)
        XCTAssertEqual(mappedBack?.sender.id, react.sender.id)
        XCTAssertEqual(mappedBack?.response, react.response)
    }

    func testInvalidContentURLReturnsNil() {
        let dto = StoredReactDTO(
            version: 1,
            id: UUID(),
            contentURL: "",
            hint: "h",
            sender: StoredUserDTO(
                id: UUID(),
                username: "u",
                displayName: "d",
                profilePictureURL: nil
            ),
            responseURL: nil
        )

        XCTAssertNil(StoredReactMapper.toDomain(dto))
    }
}
