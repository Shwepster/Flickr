//
//  PhotoLoaderCroppedTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

import XCTest
@testable import Flickr

final class PhotoLoaderCroppedTests: XCTestCase {
    private var photoLoader: PhotoLoaderCropped!
    private var flickrService: FlickrServiceMock!
    private let image = SharedTestData.image
    private var cropSize = CGSize(width: 256, height: 192)
    
    // MARK: - Setup

    override func setUp() {
        flickrService = FlickrServiceMock()
                
        let rawLoader = PhotoLoaderRaw(flickrService: flickrService)
        photoLoader = PhotoLoaderCropped(
            cropSize: cropSize,
            photoLoader: rawLoader
        )
    }
    
    override func tearDown() {
        flickrService.reset()
        flickrService = nil
        photoLoader = nil
    }
    
    // MARK: - Tests

    func testCropSizeCorrect() async {
        flickrService.data = image.pngData()
        
        let result = await loadTestImage()
        XCTAssertNotNil(result)
        
        if let result = result {
            XCTAssertEqual(result.size, cropSize)
            XCTAssertNotEqual(result.size, image.size)
        }
    }
    
    func testWithError() async {
        flickrService.data = image.pngData()
        flickrService.error = .noData
        
        let result = await loadTestImage()
        XCTAssertNil(result, "Expected nil due to error, but got a result")
    }
    
    func testWithCorruptedData() async {
        flickrService.data = Data()
        
        let result = await loadTestImage()
        XCTAssertNil(result, "Expected nil with corrupted data, but got a result")
    }
    
    func testWithEmptyData() async {
        flickrService.data = nil
        
        let result = await loadTestImage()
        XCTAssertNil(result, "Expected nil with empty data, but got a result")
    }
    
    func testPerformance() async {
        let largeImage = UIImage(resource: .testLarge)
        flickrService.data = largeImage.pngData()
        flickrService.delay = 0
        
        measure {
            let exp = expectation(description: "Finished")
            
            Task { [photoLoader] in
                for _ in 0..<5 {
                    _ = await photoLoader!.loadImage(for: .mock, size: .b)
                }
                exp.fulfill()
            }
            
            wait(for: [exp], timeout: 1)
        }
    }
    
    // MARK: - Helpers
    
    private func loadTestImage() async -> UIImage? {
        await photoLoader.loadImage(for: .mock, size: .b)
    }
}
