//
//  PhotoServiceRaw.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

struct PhotoLoaderRaw: PhotoLoader {
    private let flickrService: FlickrService
    
    init(flickrService: FlickrService) {
        self.flickrService = flickrService
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        do {
            let imageData = try await flickrService.loadImageData(for: photo, size: size)
            return UIImage(data: imageData)
        } catch is CancellationError {
            print("Loading photo was cancelled")
            return nil
        } catch {
            if let error = error as? URLError, error.errorCode == -999 {
                print("Loading photo was cancelled")
            } else {
                print("Error loading photo: \(error)")
            }
            return nil
        }
    }
}
