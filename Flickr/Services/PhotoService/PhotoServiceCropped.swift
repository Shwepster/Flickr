//
//  PhotoServiceCropped.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

struct PhotoServiceCropped: PhotoService {
    private let photoService: PhotoService
    private let cropSize: CGSize
    
    init(cropSize: CGSize, photoService: PhotoService) {
        self.cropSize = cropSize
        self.photoService = photoService
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        let image = await photoService.loadImage(for: photo, size: size)
        
        if Task.isCancelled { return nil }
        
        return await image?.byPreparingThumbnail(ofSize: cropSize)
    }
    
    func cancelPhotoLoading(for photo: PhotoDTO) {
        photoService.cancelPhotoLoading(for: photo)
    }
}
