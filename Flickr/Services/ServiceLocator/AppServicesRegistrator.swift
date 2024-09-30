//
//  AppServicesRegistrator.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

enum AppServicesRegistrator {
    static func registerAllServices() {
        registerHistoryStorage()
        registerImageCacheService()
        registerFlickrService()
        registerPhotoService()
    }
    
    static func unregisterAllServices() {
        ServiceContainer.unregisterAll()
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
    
    private static func registerImageCacheService() {
        ServiceContainer.register(ImageCacheService.self, factory: ImageCacheService())
    }
    
    private static func registerHistoryStorage() {
        ServiceContainer.register(HistoryStorage.self, factory: HistoryStorage())
    }
    
    private static func registerPhotoService() {
        ServiceContainer.register(PhotoService.self) {
            @ServiceLocator var flickrService: FlickrService
            
            var service: PhotoLoader = PhotoLoaderRaw(flickrService: flickrService)
            service = PhotoLoaderCropped(cropSize: AppSettings.croppSize, photoLoader: service)
            
            @ServiceLocator(.singleton) var cache: ImageCacheService
            service = PhotoLoaderCached(photoLoader: service, cacheService: cache)
            return PhotoService(photoLoader: service)
        }
    }
}
