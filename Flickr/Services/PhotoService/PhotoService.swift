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
    
    var activeTasks: Int {
        loadingTasks.withLock { $0.keys.count }
    }
    
    init(photoLoader: PhotoLoader) {
        self.photoLoader = photoLoader
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage? {
        if let task = loadingTasks.withLock({ $0[photo.id] }) {
            return await task.value
        }
        
        if Task.isCancelled { return nil }
               
        let newTask = Task<UIImage?, Never> {
            if Task.isCancelled { return nil }
            let image = await photoLoader.loadImage(for: photo, size: size)
            if Task.isCancelled { return nil }
            return image
        }
        
        // This eliminates case when two tasks meet at the lock above
        // First task holds the lock, while second is waiting for it
        // then first releases the lock and now second task holds the lock
        // now first task is stuck here waiting for the lock
        // after second task releases the lock above, first task captures the lock and caches the task in `loadingTasks`
        // when first task releases the lock and goes to do the work, second task now gets this lock
        // he sees that task is already cached and waits for the first task to get his result
        let runningTask: Task<UIImage?, Never>? = loadingTasks.withLock {
            if let runningTask = $0[photo.id] {
                print("Photo with id \(photo.id) is already loading")
                return runningTask
            } else {
                $0[photo.id] = newTask
                return nil
            }
        }
        
        if let runningTask {
            return await runningTask.value
        }
        
        let image = await newTask.value
        loadingTasks.withLock { $0[photo.id] = nil }
        return image
    }
    
    func cancelPhotoLoading(for photo: PhotoDTO) {
        loadingTasks.withLock { $0[photo.id]?.cancel() }
    }
    
    func cancelAllPhotoLoading() {
        loadingTasks.withLock { $0.values.forEach {
            $0.cancel()
        } }
    }
}
