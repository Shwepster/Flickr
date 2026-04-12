// PhotoListUITests.swift
// FlickrUITests

import XCTest

final class PhotoListUITests: FlickrUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        performSearch("test")
        XCTAssertTrue(waitForPhoto(id: "1"), "Photo list did not load after search")
    }

    func testPhotosLoadAfterSearch() {
        XCTAssertTrue(firstPhoto.exists)
    }

    /// Tapping a photo opens the editor in a partial sheet.
    func testTappingPhotoOpensEditor() {
        firstPhoto.tap()
        XCTAssertTrue(editorSaveButton.waitForExistence(timeout: 5))
    }

    /// Long-pressing a photo also opens the editor.
    func testLongPressingPhotoOpensEditor() {
        firstPhoto.press(forDuration: 1.5)
        XCTAssertTrue(editorSaveButton.waitForExistence(timeout: 5))
    }

    func testDeletingPhotoRemovesItFromList() {
        let deleteBtn = app.buttons[A11y.PhotoList.deleteButton("1")]
        XCTAssertTrue(deleteBtn.waitForExistence(timeout: 5))
        deleteBtn.tap()
        XCTAssertFalse(firstPhoto.waitForExistence(timeout: 3))
    }

    func testPullToRefreshReloadsList() {
        let list = app.collectionViews[A11y.PhotoList.list]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        list.swipeDown()
        XCTAssertTrue(waitForPhoto(id: "1"))
    }

    func testPaginationLoadsMorePhotos() {
        let list = app.collectionViews[A11y.PhotoList.list]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        // Scroll down three times to trigger pagination
        list.swipeUp()
        list.swipeUp()
        list.swipeUp()
        XCTAssertTrue(waitForPhoto(id: "21", timeout: 15))
    }

    func testToggleViewModeSwitchesBetweenListAndPageView() {
        XCTAssertFalse(pageViewScroll.exists)
        toolbarToggleButton.tap()
        XCTAssertTrue(pageViewScroll.waitForExistence(timeout: 5))
    }
}
