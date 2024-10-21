//
//  PageViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

import Foundation

extension PageView {
    @MainActor
    final class ViewModel: ObservableObject, Identifiable {
        typealias PhotoViewModel = PhotoItemView.ViewModel
        @Published var currentPhoto: PhotoViewModel?
        let photos: [PhotoViewModel]
        let id: String = UUID().uuidString
        private let onSelect: (PhotoViewModel) -> Void
        
        init(
            initialPhoto: PhotoViewModel?,
            photos: [PhotoViewModel],
            onSelect: @escaping (PhotoViewModel) -> Void
        ) {
            self.photos = photos
            self.onSelect = onSelect
            self.currentPhoto = initialPhoto ?? photos.first
        }
        
        deinit {
            print("PageViewModel deinit")
        }
        
        private(set) lazy var onTap: () -> Void = { [weak self] in
            if let photo = self?.currentPhoto {
                self?.onSelect(photo)
            }
        }
    }
}
