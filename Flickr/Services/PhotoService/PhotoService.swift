//
//  PhotoService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit
import Synchronization

final class PhotoService: Sendable {
    private let loadingTasks: Mutex<[String: Task<UIImage?, Never>]> = .init([:])
    private let photoLoader: PhotoLoader
    
    init(photoLoader: PhotoLoader) {
        self.photoLoader = photoLoader
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        if let task = loadingTasks.withLock({ $0[photo.id] }) {
            return await task.value
        }
        
        if Task.isCancelled { return nil }
               
        let task = Task<UIImage?, Never> {
            if Task.isCancelled { return nil }
            let image = await photoLoader.loadImage(for: photo, size: size)
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
