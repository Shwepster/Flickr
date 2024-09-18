//
//  PhotoServiceRaw.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit
import Synchronization

final class PhotoServiceRaw: PhotoService {
    private let flickrService: FlickrService
    private var imageSize: PhotoSize { AppSettings.photoSize }
    private let loadingTasks: Mutex<[String: Task<UIImage?, Never>]> = .init([:])
    
    init(flickrService: FlickrService) {
        self.flickrService = flickrService
    }
    
    func loadImage(for photo: PhotoDTO) async -> UIImage? {
        if let loadingTask = loadingTasks.withLock({ $0[photo.id] }) {
            return await loadingTask.value
        }
        
        let task = Task<UIImage?, Never> {
            defer { loadingTasks.withLock({ $0[photo.id] = nil }) }
            
            do {
                try Task.checkCancellation()
                let imageData = try await flickrService.loadImage(for: photo, size: imageSize)
                return UIImage(data: imageData)
            } catch {
                print("Error loading photo: \(error)")
                return nil
            }
        }
        
        loadingTasks.withLock { $0[photo.id] = task }
        return await task.value
    }
    
    func cancelPhotoLoading(for photo: PhotoDTO) {
        loadingTasks.withLock {
            $0[photo.id]?.cancel()
            $0[photo.id] = nil
        }
    }
}
