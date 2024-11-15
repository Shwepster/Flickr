//
//  PhotoLoaderCached.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

struct PhotoLoaderCached: PhotoLoader {
    private let photoLoader: PhotoLoader
    private let cacheService: ImageCacheService
    
    init(photoLoader: PhotoLoader, cacheService: ImageCacheService) {
        self.photoLoader = photoLoader
        self.cacheService = cacheService
    }
    
    // MARK: - Public
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        let photoId = ImageCacheService.id(for: photo, size: size)
        
        if let image = await cacheService.getImage(for: photoId) {
            return image
        }
        
        guard let image = await photoLoader.loadImage(for: photo, size: size) else {
            return nil
        }
        
        if !Task.isCancelled {
            await cacheService.cache(image: image, for: photoId)
        }
        
        return image
    }
}

extension ImageCacheService {
    static func id(for photo: PhotoDTO, size: PhotoSize? = nil) -> String {
        if let size {
            "\(photo.id)_\(size.rawValue)"
        } else {
            photo.id
        }
    }
}
