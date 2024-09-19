//
//  PhotoServiceCached.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

struct PhotoServiceCached: PhotoService {
    private let photoService: PhotoService
    private let cacheService: ImageCacheService
    
    init(photoService: PhotoService, cacheService: ImageCacheService) {
        self.photoService = photoService
        self.cacheService = cacheService
    }
    
    // MARK: - Public
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        let photoId = id(for: photo, size: size)
        
        if let image = await cacheService.getImage(for: photoId) {
            return image
        }
        
        guard let image = await photoService.loadImage(for: photo, size: size) else {
            return nil
        }
        
        if !Task.isCancelled {
            await cacheService.cache(image: image, for: photoId)
        }
        
        return image
    }
    
    func cancelPhotoLoading(for photo: PhotoDTO) {
        photoService.cancelPhotoLoading(for: photo)
    }
    
    // MARK: - Private
    
    private func id(for photo: PhotoDTO, size: PhotoSize) -> String {
        "\(photo.id)_\(size.rawValue)"
    }
}
