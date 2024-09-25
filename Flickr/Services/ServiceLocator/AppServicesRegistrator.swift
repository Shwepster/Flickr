//
//  AppServicesRegistrator.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

enum AppServicesRegistrator {
    static func registerAllServices() {
        registerFlickrService()
        registerPhotoService()
    }
    
    // MARK: - Individual registrations
    
    private static func registerFlickrService() {
        ServiceContainer.register(FlickrService.self) {
            guard let key = ProcessInfo.processInfo.environment["KEY"] else {
                fatalError("Missing environment variable KEY for FlickrService.")
            }
            
            let service = FlickrServiceDefault(
                httpClient: HTTPClient(),
                requestBuilder: FlickrRequestBuilder(key: key)
            )
            
            return service
        }
    }
    
    private static func registerPhotoService() {
        ServiceContainer.register(PhotoService.self) {
            @ServiceLocator var flickrService: FlickrService
            
            var service: PhotoLoader = PhotoLoaderRaw(flickrService: flickrService)
            service = PhotoLoaderCropped(cropSize: AppSettings.photoSize.cgSize, photoLoader: service)
            
            let cache = ImageCacheService()
            service = PhotoLoaderCached(photoLoader: service, cacheService: cache)
            return PhotoService(photoLoader: service)
        }
    }
}
