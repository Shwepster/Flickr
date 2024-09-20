//
//  ImageCacheTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import XCTest
@testable import Flickr

final class ImageCacheTests: XCTestCase {
    private var service: ImageCacheService!
    
    private var image = UIImage(resource: .test)
    private let id = "image"
    private let image2 = UIImage(resource: .test2)
    private let id2 = "image2"
    
    override func setUp() async throws {
        service = ImageCacheService()
        await service.clearCache()
    }
    
    override func tearDown() async throws {
        await service.clearCache()
        service = nil
    }
    
    func testSavingToCache() async throws {
        await cacheAndValidate(image: image, id: id)
        await cacheAndValidate(image: image2, id: id2)
    }
    
    func testReplacingCachedImage() async throws {
        await cacheAndValidate(image: image, id: id)
        await cacheAndValidate(image: image2, id: id2)

        // Replace second image with first image
        await service.cache(image: image, for: id2)
                
        // if first unchanged
        if let cacheImage = await service.getImage(for: id) {
            XCTAssertTrue(testImagesEqual(cached: cacheImage,
                                          compressedOriginal: compressedVersion(for: image)))
        } else {
            XCTFail("Image not found in cache")
        }
        
        // if second changed with first
        if let cachedImage2 = await service.getImage(for: id2) {
            XCTAssertTrue(testImagesEqual(cached: cachedImage2,
                                          compressedOriginal: compressedVersion(for: image)))
        } else {
            XCTFail("Image not found in cache")
        }
    }
    
    func testFetchingImage() async throws {
        var cachedImage = await service.getImage(for: id)
        XCTAssertNil(cachedImage)
        
        await cacheAndValidate(image: image, id: id)
        
        // check if it won't return cached image from 'id'
        cachedImage = await service.getImage(for: id2)
        XCTAssertNil(cachedImage)
    }
    
    func testClearingCache() async throws {
        await cacheAndValidate(image: image, id: id)
        await cacheAndValidate(image: image, id: id2)
        
        await service.clearCache()
        
        // Ensure both images are cleared
        let cachedImage = await service.getImage(for: id)
        XCTAssertNil(cachedImage)
        let cachedImage2 = await service.getImage(for: id2)
        XCTAssertNil(cachedImage2)
    }
    
    func testConcurrentAccess() async throws {
        await withTaskGroup(of: Void.self) { [image, compressedImage, service] group in
            func cacheAndValidate(image: UIImage, id: String) async {
                await service!.cache(image: image, for: id)
                
                let cachedImage = await service!.getImage(for: id)
                XCTAssertNotNil(cachedImage)
                
                XCTAssertTrue(
                    cachedImage!.pngData() == compressedImage.pngData()
                )
            }
            
            let range = 1...10
            
            for i in range {
                group.addTask {
                    let id = "\(i)"
                    await cacheAndValidate(image: image, id: id)
                }
                
                group.addTask {
                    let id = "\(i)"
                    await cacheAndValidate(image: image, id: id)
                }
            }
            
            await group.waitForAll()
            
            for i in range {
                group.addTask {
                    let id = "\(i)"
                    let cachedImage = await service!.getImage(for: id)
                    XCTAssertNotNil(cachedImage)
                }
            }
        }
    }

    // MARK: - Helpers
    
    func cacheAndValidate(image: UIImage, id: String) async {
        await service.cache(image: image, for: id)
       
        let cachedImage = await service.getImage(for: id)
        XCTAssertNotNil(cachedImage)
        
        let compressedOriginal = compressedVersion(for: image)
        XCTAssertTrue(testImagesEqual(cached: cachedImage!, compressedOriginal: compressedOriginal))
    }
    
    lazy var compressedImage = UIImage(data: image.jpegData(compressionQuality: 1)!)!
    lazy var compressedImage2 = UIImage(data: image2.jpegData(compressionQuality: 1)!)!
    
    func testImagesEqual(cached: UIImage, compressedOriginal: UIImage) -> Bool {
        cached.pngData() == compressedOriginal.pngData()
    }
    
    func compressedVersion(for image: UIImage) -> UIImage {
        switch image {
            case self.image:
                return compressedImage
            case self.image2:
                return compressedImage2
            default: return UIImage(data: image.jpegData(compressionQuality: 1)!)!
        }
    }
}
