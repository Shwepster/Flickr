//
//  AppServicesRegistratorTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 25.09.2024.
//

import XCTest
@testable import Flickr

final class AppServicesRegistratorTests: XCTestCase {
    override func setUp() {
        AppServicesRegistrator.registerAllServices()
    }
    
    func testFlickrServiceResolution() throws {
        let key = ProcessInfo.processInfo.environment["KEY"]
        let flickrService: FlickrService = try ServiceContainer.resolve(lifetime: .singleton)
        
        if let flickrServiceDefault = flickrService as? FlickrServiceDefault {
            XCTAssertEqual(
                flickrServiceDefault.key,
                key,
                "`FlickrService` should be initialized with the correct API key from the environment variable"
            )
        } else {
            XCTFail("`FlickrService` should be of type `FlickrServiceDefault`")
        }
    }
    
    func testPhotoServiceResolution() throws {
        let photoService: PhotoService = try ServiceContainer.resolve(lifetime: .singleton)
        XCTAssertNotNil(photoService)
    }
}
