//
//  PhotoLoaderRawTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

import XCTest
@testable import Flickr

final class PhotoLoaderRawTests: XCTestCase {
    private var photoLoader: PhotoLoaderRaw!
    private var flickrService: FlickrServiceMock!
    private let image = SharedTestData.image

    // MARK: - Setup

    override func setUp() {
        flickrService = FlickrServiceMock()
        photoLoader = PhotoLoaderRaw(flickrService: flickrService)
    }
    
    override func tearDown() {
        flickrService.reset()
        photoLoader = nil
        flickrService = nil
    }
    
    // MARK: - Tests

    func testImageLoadingSuccess() async {
        flickrService.data = image.pngData()
        
        let result = await loadTestImage()
        XCTAssertNotNil(result)
        
        XCTAssertEqual(
            result?.pngData(),
            image.pngData(),
            "Expected image data does not match loaded image data"
        )
    }
    
    func testImageLoadingError() async {
        flickrService.data = image.pngData()
        flickrService.error = .other
        
        let result = await loadTestImage()
        XCTAssertNil(result, "Expected nil due to error, but got a result")
    }
    
    func testImageLoadingNoData() async {
        flickrService.data = nil
        flickrService.error = nil
        
        let result = await loadTestImage()
        XCTAssertNil(result, "Expected nil with no data, but got a result")
    }
    
    func testImageLoadingCorruptedData() async {
        flickrService.data = Data() // Empty or invalid data
        
        let result = await loadTestImage()
        XCTAssertNil(result, "Expected nil for corrupted image data")
    }
    
    // MARK: - Helpers
    
    private func loadTestImage() async -> UIImage? {
        await photoLoader.loadImage(for: .mock, size: .b)
    }
}
