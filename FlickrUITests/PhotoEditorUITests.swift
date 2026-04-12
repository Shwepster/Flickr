// PhotoEditorUITests.swift
// FlickrUITests

import XCTest

final class PhotoEditorUITests: FlickrUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        performSearch("test")
        XCTAssertTrue(waitForPhoto(id: "1"), "Photo list did not load after search")
    }

    private func openEditor() {
        firstPhoto.tap()
        XCTAssertTrue(editorSaveButton.waitForExistence(timeout: 5), "Editor did not open")
    }

    func testEditorShowsImageSliderAndSave() {
        openEditor()
        XCTAssertTrue(app.otherElements[A11y.Editor.image].exists)
        XCTAssertTrue(app.sliders[A11y.Editor.slider].exists)
        XCTAssertTrue(editorSaveButton.exists)
    }

    func testHueSliderAdjustmentUpdatesAngleLabel() {
        openEditor()
        let slider = app.sliders[A11y.Editor.slider]
        let angleLabel = app.staticTexts[A11y.Editor.angleValue]
        XCTAssertTrue(slider.waitForExistence(timeout: 5))
        XCTAssertTrue(angleLabel.waitForExistence(timeout: 5))
        let before = angleLabel.label
        slider.adjust(toNormalizedSliderPosition: 0.8)
        XCTAssertNotEqual(angleLabel.label, before)
    }

    func testSaveButtonDismissesEditor() {
        openEditor()
        editorSaveButton.tap()
        XCTAssertTrue(app.navigationBars["Flickr"].waitForExistence(timeout: 5))
    }
}
