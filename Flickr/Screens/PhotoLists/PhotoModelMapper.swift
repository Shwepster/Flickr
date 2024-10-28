//
//  PhotoModelMapper.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 28.10.2024.
//

import SwiftUI

struct PhotoModelMapper {
    @ServiceLocator(.singleton) private var cacheManager: ImageCacheService
    private let photoSize = AppSettings.photoSize
    
    func map(_ photos: [PhotoDTO]) async -> [PhotoModel] {
        await photos.asyncMap { photo in
            let image = await getImage(for: photo)
            return PhotoModel(photo: photo, image: image)
        }
    }
    
    private func getImage(for photo: PhotoDTO) async -> Image? {
        let imageId = ImageCacheService.id(for: photo, size: photoSize)

        if let image = await cacheManager.getImage(for: imageId) {
            return Image(uiImage: image)
        }
        
        return nil
    }
}
