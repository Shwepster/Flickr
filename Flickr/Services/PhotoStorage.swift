//
//  PhotoStorage.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 23.10.2024.
//

import SwiftUI
import Combine

actor PhotoStorage {
    private(set) var photos: [PhotoModel] = []
    private var continuations: [UUID: AsyncStream<UpdateEvent>.Continuation] = [:]
    
    func addPhotos(_ photos: [PhotoModel]) {
        self.photos.append(contentsOf: photos)
        notifySubscribers(about: .append(photos))
    }

    func replacePhotos(with photos: [PhotoModel]) {
        self.photos = photos
        notifySubscribers(about: .replace(photos))
    }
    
    func updatePhoto(_ photo: PhotoModel) {
        guard let index = photos.firstIndex(of: photo) else { return }
        photos[index] = photo
        notifySubscribers(about: .update(photo))
    }
    
    func removePhoto(_ photo: PhotoModel) {
        guard let index = photos.firstIndex(of: photo) else { return }
        photos.remove(at: index)
        notifySubscribers(about: .remove(photo))
    }
    
    // Allow multiple observers and manage continuations with UUIDs
    func observePhotoUpdates() -> AsyncStream<UpdateEvent> {
        let uuid = UUID()
        
        return AsyncStream { continuation in
            continuations[uuid] = continuation
            
            // Handle cancellation
            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeContinuation(uuid: uuid)
                }
            }
        }
    }
    
    // Remove a continuation from the dictionary
    private func removeContinuation(uuid: UUID) {
        continuations.removeValue(forKey: uuid)
    }
    
    // Notify all subscribers of the change
    private func notifySubscribers(about event: UpdateEvent) {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }
}

// MARK: - PhotoModel
struct PhotoModel: Equatable {
    /// ID for UI iteration, for Photo id use `photo`
    let iterationId = UUID().uuidString
    let photo: PhotoDTO
    var image: Image?
    
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        lhs.photo.id == rhs.photo.id
    }
}

// MARK: - UpdateEvent
extension PhotoStorage {
    enum UpdateEvent {
        case update(PhotoModel)
        case remove(PhotoModel)
        case replace([PhotoModel])
        case append([PhotoModel])
    }
}
