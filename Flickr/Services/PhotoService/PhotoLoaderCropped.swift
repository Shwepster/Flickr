//
//  PhotoServiceCropped.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

struct PhotoLoaderCropped: PhotoLoader {
    private let photoLoader: PhotoLoader
    private let cropSize: CGSize
    
    init(cropSize: CGSize, photoLoader: PhotoLoader) {
        self.cropSize = cropSize
        self.photoLoader = photoLoader
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        let image = await photoLoader.loadImage(for: photo, size: size)
        
        if Task.isCancelled { return nil }
        
        return await image?.byPreparingThumbnail(ofSize: cropSize)
    }
}
