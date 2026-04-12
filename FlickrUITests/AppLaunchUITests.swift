// AppLaunchUITests.swift
// FlickrUITests

import XCTest

final class AppLaunchUITests: FlickrUITestCase {

    func testAppLaunchesToMainScreen() {
        XCTAssertTrue(app.navigationBars["Flickr"].waitForExistence(timeout: 5))
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testLaunchScreenshot() {
        _ = app.navigationBars["Flickr"].waitForExistence(timeout: 5)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
