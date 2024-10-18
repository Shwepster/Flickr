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
        let photoViewModel: PhotoItemView.ViewModel
        let id = UUID().uuidString
        @ServiceLocator(.singleton) private var logger: FlickrLogger
        
        init(photoViewModel: PhotoItemView.ViewModel) {
            self.photoViewModel = photoViewModel
            self.editedImage = photoViewModel.image ?? .init(systemName: "pencil")
        }
        
        func onSave() {
            logger.logEvent(.special)
            
            let uiImage = editedImage
                .hueRotation(.degrees(hueRotation))
                .asUIImage()
            
            if let uiImage {
                photoViewModel.image = Image(uiImage: uiImage)
            }
            
            needsDismiss = true
        }
    }
}
