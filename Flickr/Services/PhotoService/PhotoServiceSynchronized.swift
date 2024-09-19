//
//  PhotoServiceSynchronized.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit
import Synchronization

final class PhotoServiceSynchronized: PhotoService {
    private let loadingTasks: Mutex<[String: Task<UIImage?, Never>]> = .init([:])
    private let photoService: PhotoService
    
    init(photoService: PhotoService) {
        self.photoService = photoService
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        if let task = loadingTasks.withLock({ $0[photo.id] }) {
            return await task.value
        }
        
        if Task.isCancelled { return nil }
               
        let task = Task<UIImage?, Never> {
            if Task.isCancelled { return nil }
            let image = await photoService.loadImage(for: photo, size: size)
            if Task.isCancelled { return nil }
            return image
        }
        
        loadingTasks.withLock { $0[photo.id] = task }
        let image = await task.value
        loadingTasks.withLock { $0[photo.id] = nil }
        
        return image
    }
    
    func cancelPhotoLoading(for photo: PhotoDTO) {
        loadingTasks.withLock { $0[photo.id]?.cancel() }
    }
}
