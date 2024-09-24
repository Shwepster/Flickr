//
//  AppServices.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

final class AppServices: @unchecked Sendable {
    static let shared = AppServices()
    private init() {}
    
    private(set) lazy var flickrService: FlickrService = {
        let key = ProcessInfo.processInfo.environment["KEY"]!
        
        return FlickrServiceDefault(
            httpClient: HTTPClient(),
            requestBuilder: FlickrRequestBuilder(key: key)
        )
    }()
    
    private(set) lazy var photoService: PhotoService = {
        var service: PhotoLoader = PhotoLoaderRaw(flickrService: flickrService)
        service = PhotoLoaderCropped(cropSize: AppSettings.photoSize.cgSize, photoLoader: service)
        
        let cache = ImageCacheService()
        service = PhotoLoaderCached(photoLoader: service, cacheService: cache)
        return .init(photoLoader: service)
    }()
}
