//
//  EditorViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 11.10.2024.
//

import Foundation
import SwiftUI

extension EditorView {
    @MainActor
    final class ViewModel: ObservableObject, Identifiable {
        @Published var editedImage: Image
        @Published var hueRotation = 0.0
        @Published var needsDismiss: Bool = false
        let angleRange = 0.0...360
        let id = UUID().uuidString
        private var photo: PhotoModel
        @ServiceLocator(.singleton) private var logger: FlickrLogger
        @ServiceLocator(.singleton) private var photoStorage: PhotoStorage
        
        init(photo: PhotoModel) {
            self.photo = photo
            self.editedImage = photo.image ?? .init(systemName: "pencil")
        }
        
        func onSave() {
            logger.logEvent(.special)
            
            let uiImage = editedImage
                .hueRotation(.degrees(hueRotation))
                .asUIImage()
            
            if let uiImage {
                Task {
                    photo.image = Image(uiImage: uiImage)
                    await photoStorage.updatePhoto(photo)
                }
            }
            
            needsDismiss = true
        }
    }
}
