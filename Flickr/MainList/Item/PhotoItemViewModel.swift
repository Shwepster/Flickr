//
//  PhotoItemViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import SwiftUI

extension PhotoItemView {
    @MainActor
    final class ViewModel: ObservableObject, Identifiable {
        typealias ViewModel = PhotoItemView.ViewModel
        @Published var image: Image?
        let title: String
        nonisolated var photoId: String { photo.id }
        nonisolated var id: String { photo.iterationId }
        nonisolated private let photo: PhotoDTO
        nonisolated private let photoService: PhotoService
        private let photoSize = AppSettings.photoSize
        private let onDeleteCallback: (ViewModel) -> Void
        private let onEditCallback: (ViewModel) -> Void
        
        init(
            photo: PhotoDTO,
            onDelete: @escaping (ViewModel) -> Void = { _ in },
            onEdit: @escaping (ViewModel) -> Void = { _ in }
        ) {
            self.photo = photo
            self.onDeleteCallback = onDelete
            self.onEditCallback = onEdit
            self.title = (photo.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            do {
                photoService = try ServiceContainer.resolve(lifetime: .singleton)
            } catch {
                fatalError("Failed to resolve photo service: \(error)")
            }
        }
        
        deinit {
            photoService.cancelPhotoLoading(for: photo)
            print("Photo item view model deinitialized")
        }
        
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
        
        // MARK: - Private
        
        private func loadImage() async {
            let imageTask = Task.detached { [photo, photoSize, photoService] in
                await photoService.loadImage(for: photo, size: photoSize)
            }
            
            if let uiImage = await imageTask.value {
                image = Image(uiImage: uiImage)
            } else {
                image = Image(systemName: "photo.circle.fill")
            }
        }
    }
}

extension PhotoItemView.ViewModel: Equatable {
    nonisolated public static func == (lhs: PhotoItemView.ViewModel, rhs: PhotoItemView.ViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
