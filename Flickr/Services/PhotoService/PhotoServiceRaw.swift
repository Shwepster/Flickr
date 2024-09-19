//
//  PhotoServiceRaw.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

struct PhotoServiceRaw: PhotoService {
    private let flickrService: FlickrService
    
    init(flickrService: FlickrService) {
        self.flickrService = flickrService
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        do {
            let imageData = try await flickrService.loadImage(for: photo, size: size)
            return UIImage(data: imageData)
        } catch {
            print("Error loading photo: \(error)")
            return nil
        }
    }
    
    func cancelPhotoLoading(for photo: PhotoDTO) {}
}
