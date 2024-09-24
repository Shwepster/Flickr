//
//  PhotoLoaderCachedTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

import XCTest
@testable import Flickr

final class PhotoLoaderCachedTests: XCTestCase {
    private var photoLoader: PhotoLoaderCached!
    private var flickrService: FlickrServiceMock!
    private var cacheService: ImageCacheService!
    private let image = SharedTestData.image
    
    // MARK: - Setup

    override func setUp() async throws {
        flickrService = FlickrServiceMock()
        cacheService = ImageCacheService()
        let rawLoader = PhotoLoaderRaw(flickrService: flickrService)
        photoLoader = PhotoLoaderCached(photoLoader: rawLoader, cacheService: cacheService)
    }
    
    override func tearDown() async throws {
        await cacheService.clearCache()
        flickrService = nil
        photoLoader = nil
        cacheService = nil
    }
    
    // MARK: - Tests
    
    func testImageLoadedFromCacheWhenNoData() async {
        await cacheImageAndAssert(for: .mock, size: .b)
        flickrService.data = nil
        
        // get from cache even if there is no data
        let result = await photoLoader.loadImage(for: .mock, size: .b)
        XCTAssertNotNil(result)
    }
    
    func testImageLoadedFromCacheOnServiceError() async {
        await cacheImageAndAssert(for: .mock, size: .b)
        flickrService.error = .other
        
        // get from cache even if service throws error
        let result = await photoLoader.loadImage(for: .mock, size: .b)
        XCTAssertNotNil(result, "Expected to load from cache despite error in service.")
    }
    
    func testImageLoadedFromCacheWithCorruptedData() async {
        await cacheImageAndAssert(for: .mock, size: .b)
        flickrService.data = Data() // Simulating corrupted data
        
        let result = await photoLoader.loadImage(for: .mock, size: .b)
        XCTAssertNotNil(result, "Expected to load from cache despite corrupted data from service.")
    }
    
    func testImageLoadingWhenNoCache() async {
        await cacheImageAndAssert(for: .mock, size: .b)
        await cacheService.clearCache()
        flickrService.data = nil
        
        // get nil, because cache should be empty
        let result = await photoLoader.loadImage(for: .mock, size: .b)
        XCTAssertNil(result, "Expected to fail, due empty cache and empty service.")
    }
    
    // MARK: - Helpers
    
    private func cacheImageAndAssert(for photo: PhotoDTO, size: PhotoSize) async {
        flickrService.data = image.pngData()
        
        // trigger successful loading, so image will be cached
        let result = await photoLoader.loadImage(for: photo, size: size)
        XCTAssertNotNil(result)
    }
}
