//
//  AppServices.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

final class AppServices {
    static let shared = AppServices()
    private init() {}
    
    private(set) lazy var flickrService: FlickrService = {
        let key = ProcessInfo.processInfo.environment["KEY"]!
        
        return FlickrService(
            httpClient: HTTPClient(),
            requestBuilder: FlickrRequestBuilder(key: key)
        )
    }()
    
    private(set) lazy var photoService: PhotoService = PhotoServiceRaw(flickrService: flickrService)
}
