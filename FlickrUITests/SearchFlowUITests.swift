// SearchFlowUITests.swift
// FlickrUITests

import XCTest

final class SearchFlowUITests: FlickrUITestCase {

    func testSearchFieldIsVisibleOnLaunch() {
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    func testTypingInSearchFieldAcceptsText() {
        searchField.tap()
        searchField.typeText("cats")
        XCTAssertEqual(searchField.value as? String, "cats")
    }

    func testSubmittingSearchLoadsPhotoResults() {
        performSearch("cats")
        XCTAssertTrue(waitForPhoto(id: "1"))
    }

    func testEmptyResultsStateShowsNoErrorView() {
        launchApp(extraArgs: ["-ui-testing-empty-results"])
        performSearch("nothing")
        // Stub returns empty list — no error banner should appear
        let error = app.descendants(matching: .any).matching(identifier: A11y.PhotoList.error).firstMatch
        XCTAssertFalse(error.waitForExistence(timeout: 3))
    }
}
