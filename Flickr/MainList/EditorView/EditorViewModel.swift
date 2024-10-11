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
        let photoViewModel: PhotoItemView.ViewModel
        let id = UUID().uuidString
        private let onSaveCallback: () -> Void
        
        init(photoViewModel: PhotoItemView.ViewModel, onSave: @escaping () -> Void = {}) {
            self.photoViewModel = photoViewModel
            self.onSaveCallback = onSave
            self.editedImage = photoViewModel.image ?? .init(systemName: "pencil")
        }
        
        func onSave() {
            photoViewModel.image = editedImage
            onSaveCallback()
        }
        
        func onModify() {
            let uiImage = editedImage
                .hueRotation(.degrees(Double.random(in: 30...330)))
                .asUIImage()
            
            if let uiImage {
                editedImage = Image(uiImage: uiImage)
            }
        }
    }
}
