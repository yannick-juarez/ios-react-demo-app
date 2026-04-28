//
//  AppGroupReactInboxStoreTests.swift
//  CorePersistenceTests
//

import XCTest
import CoreDomain
@testable import CorePersistence

final class AppGroupReactInboxStoreTests: XCTestCase {

    func test_saveAndReturnShareID() throws {
        let testData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG magic bytes
        let testHint = "Test hint for share"
        
        let shareID = try AppGroupReactInboxStore.saveIncomingImageAndReturnShareID(
            testData,
            hint: testHint,
            preferredFileExtension: "png"
        )
        
        XCTAssertFalse(shareID.isEmpty, "shareID should be generated")
        XCTAssertTrue(AppGroupReactInboxStore.hasPendingDraft(), "Should have pending draft after save")
    }
    
    func test_saveWithEmptyExtensionUsesDefault() throws {
        let testData = Data([0xFF, 0xD8, 0xFF, 0xE0]) // JPEG magic bytes
        let testHint = "Test"
        
        let shareID = try AppGroupReactInboxStore.saveIncomingImageAndReturnShareID(
            testData,
            hint: testHint,
            preferredFileExtension: "" // Empty should default to jpg
        )
        
        XCTAssertFalse(shareID.isEmpty)
    }
    
    func test_normalizeEmptyHint() throws {
        let testData = Data([0x89, 0x50, 0x4E, 0x47])
        let emptyHint = "   " // Whitespace only
        
        _ = try AppGroupReactInboxStore.saveIncomingImageAndReturnShareID(
            testData,
            hint: emptyHint
        )
        
        if let draft = AppGroupReactInboxStore.consumeLatestDraft() {
            XCTAssertEqual(draft.hint, "No hint", "Whitespace-only hint should be normalized to 'No hint'")
        }
    }
}
