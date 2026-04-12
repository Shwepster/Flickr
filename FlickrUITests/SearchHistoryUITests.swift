// SearchHistoryUITests.swift
// FlickrUITests

import XCTest

final class SearchHistoryUITests: FlickrUITestCase {

    func testEmptyHistoryStateShownWhenNoSearches() {
        searchField.tap()
        XCTAssertTrue(
            app.staticTexts[A11y.Search.historyEmpty].waitForExistence(timeout: 5)
        )
    }

    func testRecentSearchesAppearInHistory() {
        performSearch("dog")
        XCTAssertTrue(waitForPhoto(id: "1"))
        searchField.tap()
        XCTAssertTrue(
            app.descendants(matching: .any)
                .matching(identifier: A11y.Search.historyItem("dog"))
                .firstMatch
                .waitForExistence(timeout: 5)
        )
    }

    func testTappingHistoryItemReRunsSearch() {
        performSearch("dog")
        XCTAssertTrue(waitForPhoto(id: "1"))
        searchField.tap()
        app.descendants(matching: .any)
            .matching(identifier: A11y.Search.historyItem("dog"))
            .firstMatch
            .tap()
        XCTAssertTrue(waitForPhoto(id: "1"))
    }

    func testDeletingHistoryItemRemovesIt() {
        performSearch("dog")
        XCTAssertTrue(waitForPhoto(id: "1"))
        searchField.tap()
        let deleteBtn = app.buttons[A11y.Search.historyDelete("dog")]
        XCTAssertTrue(deleteBtn.waitForExistence(timeout: 5))
        deleteBtn.tap()
        let historyItem = app.descendants(matching: .any)
            .matching(identifier: A11y.Search.historyItem("dog"))
            .firstMatch
        XCTAssertFalse(historyItem.waitForExistence(timeout: 3))
    }

    func testClearingAllHistoryShowsEmptyState() {
        performSearch("dog")
        XCTAssertTrue(waitForPhoto(id: "1"))
        searchField.tap()
        let clearBtn = app.buttons[A11y.Search.historyClear]
        XCTAssertTrue(clearBtn.waitForExistence(timeout: 5))
        clearBtn.tap()
        XCTAssertTrue(
            app.staticTexts[A11y.Search.historyEmpty].waitForExistence(timeout: 5)
        )
    }
}
