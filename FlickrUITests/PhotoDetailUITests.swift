// PhotoDetailUITests.swift
// FlickrUITests
//
// Tests the inline page view, which is activated by the toolbar toggle button.

import XCTest

final class PhotoDetailUITests: FlickrUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        performSearch("test")
        XCTAssertTrue(waitForPhoto(id: "1"), "Photo list did not load after search")
        // Switch to page view mode via the toolbar toggle
        toolbarToggleButton.tap()
        XCTAssertTrue(pageViewScroll.waitForExistence(timeout: 5), "Page view did not appear after toggle")
    }

    func testPageViewShowsFocusedPhoto() {
        XCTAssertTrue(pageElement(id: "1").waitForExistence(timeout: 5))
    }

    func testHorizontalSwipeChangesPage() {
        pageViewScroll.swipeLeft()
        XCTAssertTrue(pageElement(id: "2").waitForExistence(timeout: 5))
    }

    func testToggleBackToListView() {
        toolbarToggleButton.tap()
        let list = app.collectionViews[A11y.PhotoList.list]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
    }
}
