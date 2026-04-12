// FlickrUITestCase.swift
// FlickrUITests
//
// Base class for all Flickr UI tests. Boots the app in UI-testing mode
// (deterministic stub, clean history) and provides shared helpers.

import XCTest

class FlickrUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch helpers

    /// Terminates and relaunches the app with additional launch arguments on
    /// top of the default "-ui-testing" flag.
    func launchApp(extraArgs: [String]) {
        app.terminate()
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"] + extraArgs
        app.launch()
    }

    // MARK: - Convenience accessors

    var searchField: XCUIElement {
        app.searchFields.firstMatch
    }

    var toolbarToggleButton: XCUIElement {
        app.buttons[A11y.Main.toolbarToggleView]
    }

    var editorSaveButton: XCUIElement {
        app.buttons[A11y.Editor.save]
    }

    var pageViewScroll: XCUIElement {
        app.scrollViews[A11y.PageView.scroll]
    }

    var firstPhoto: XCUIElement {
        photoElement(id: "1")
    }

    func photoElement(id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: A11y.PhotoList.item(id)).firstMatch
    }

    func pageElement(id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: A11y.PageView.page(id)).firstMatch
    }

    // MARK: - Wait helpers

    /// Waits up to `timeout` seconds for the photo with the given id to appear.
    @discardableResult
    func waitForPhoto(id: String, timeout: TimeInterval = 10) -> Bool {
        photoElement(id: id).waitForExistence(timeout: timeout)
    }

    // MARK: - Search helper

    /// Types `query` into the search field and submits via the Return key.
    func performSearch(_ query: String) {
        searchField.tap()
        searchField.typeText(query + "\n")
    }
}
