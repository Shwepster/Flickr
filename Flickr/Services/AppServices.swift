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
        
        return FlickrService(
            httpClient: HTTPClient(),
            requestBuilder: FlickrRequestBuilder(key: key)
        )
    }()
    
    private(set) lazy var photoService: PhotoService = {
        var service: PhotoService = PhotoServiceRaw(flickrService: flickrService)
        service = PhotoServiceCropped(cropSize: AppSettings.photoSize.cgSize, photoService: service)
        
        let cache = ImageCacheService()
        service = PhotoServiceCached(photoService: service, cacheService: cache)
        service = PhotoServiceSynchronized(photoService: service)
        return service
    }()
}
