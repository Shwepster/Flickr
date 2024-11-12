//
//  PhotoItemViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import SwiftUI
import Synchronization

extension PhotoItemView {
    @MainActor
    final class ViewModel: ObservableObject {
        typealias ViewModel = PhotoItemView.ViewModel
        @Published var image: Image?
        let title: String
        nonisolated var photo: PhotoModel { _photo.withLock { $0 } }
        private let _photo: Mutex<PhotoModel>
        nonisolated private let photoService: PhotoService
        private let photoStorage: PhotoStorage
        private let photoSize = AppSettings.photoSize
        private let onDeleteCallback: (ViewModel) -> Void
        private let onEditCallback: (ViewModel) -> Void
        private let onSelectCallback: (ViewModel) -> Void
        
        init(
            photo: PhotoModel,
            onDelete: @escaping (ViewModel) -> Void = { _ in },
            onEdit: @escaping (ViewModel) -> Void = { _ in },
            onSelect: @escaping (ViewModel) -> Void = { _ in }
        ) {
            self._photo = .init(photo)
            self.image = photo.image?.asImage()
            self.title = (photo.photo.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            self.onDeleteCallback = onDelete
            self.onEditCallback = onEdit
            self.onSelectCallback = onSelect
            
            do {
                photoService = try ServiceContainer.resolve(lifetime: .singleton)
                photoStorage = try ServiceContainer.resolve(lifetime: .singleton)
            } catch {
                fatalError("Failed to resolve service: \(error)")
            }
        }
        
        deinit {
            photoService.cancelPhotoLoading(for: photo.photo)
            print("Photo item view model deinitialized")
        }
        
        // MARK: - Actions
        
        func onCreated() async {
            if image == nil {
                await loadImage()
            }
        }
        
        func onEdit() {
            onEditCallback(self)
        }
        
        func onDelete() {
            onDeleteCallback(self)
        }
        
        func onSelect() {
            onSelectCallback(self)
        }
        
        // MARK: - Other
        
        func updatePhoto(_ photo: PhotoModel) {
            self._photo.withLock { $0 = photo }
            image = photo.image?.asImage()
        }
        
        // MARK: - Private
        
        private func loadImage() async {
            var photo = _photo.withLock { $0 }
            let imageTask = Task.detached { [photoSize, photoService] in
                await photoService.loadImage(for: photo.photo, size: photoSize)
            }
            
            if let uiImage = await imageTask.value {
                photo.image = uiImage
                image = Image(uiImage: uiImage)
            } else {
                image = Image(systemName: "photo.circle.fill")
                photo.image = image?.asUIImage()
            }
            
            _photo.withLock { $0 = photo }
            await photoStorage.updatePhoto(photo)
        }
    }
}

// MARK: - Protocols
extension PhotoItemView.ViewModel: Identifiable {
    nonisolated var id: String { photo.iterationId }
}

extension PhotoItemView.ViewModel: Equatable {
    nonisolated public static func == (lhs: PhotoItemView.ViewModel, rhs: PhotoItemView.ViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension PhotoItemView.ViewModel: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
