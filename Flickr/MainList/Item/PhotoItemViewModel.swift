//
//  PhotoItemViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import SwiftUI

extension PhotoItemView {
    @MainActor
    final class ViewModel: ObservableObject {
        nonisolated private let photoService: PhotoService
        nonisolated let photo: PhotoDTO
        private let photoSize = AppSettings.photoSize
        @Published var image: Image?
        
        init(photo: PhotoDTO) {
            self.photo = photo
            do {
                photoService = try ServiceContainer.resolve(lifetime: .singleton)
            } catch {
                fatalError("Failed to resolve photo service: \(error)")
            }
        }
        
        deinit {
            print("deinit")
            photoService.cancelPhotoLoading(for: photo)
        }
        
        func onCreated() {
            Task(priority: .high) {
                await loadImage()                
            }
        }
        
        private func loadImage() async {
            let imageTask = Task(priority: .high) { [photo, photoSize, photoService] in
                await photoService.loadImage(for: photo, size: photoSize)
            }
            
            if let uiImage = await imageTask.value {
                image = Image(uiImage: uiImage)
            } else {
                image = Image(.placeholder) // default image
            }            
        }
    }
}
