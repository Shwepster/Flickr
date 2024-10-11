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
        let angleRange = 0.0...360
        let photoViewModel: PhotoItemView.ViewModel
        let id = UUID().uuidString
        private let onSaveCallback: () -> Void
        
        init(photoViewModel: PhotoItemView.ViewModel, onSave: @escaping () -> Void = {}) {
            self.photoViewModel = photoViewModel
            self.onSaveCallback = onSave
            self.editedImage = photoViewModel.image ?? .init(systemName: "pencil")
        }
        
        func onSave() {
            let uiImage = editedImage
                .hueRotation(.degrees(hueRotation))
                .asUIImage()
            
            if let uiImage {
                photoViewModel.image = Image(uiImage: uiImage)
            }
            
            onSaveCallback()
        }
    }
}
