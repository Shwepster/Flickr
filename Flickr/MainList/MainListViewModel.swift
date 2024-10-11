//
//  MainListViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import Foundation

extension MainListView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var photos: [PhotoItemView.ViewModel] = []
        @Published var state: State = .idle
        //TODO: add popup error
        private let paginationController: FlickrSearchPaginationController
        
        init(paginationController: FlickrSearchPaginationController = FlickrSearchPaginationControllerDefault(
            perPage: AppSettings.photosPerPage
        )) {
            self.paginationController = paginationController
        }
        
        func refresh() async {
            paginationController.resetPages()
            await loadNextPage(replacePhotos: true)
        }
        
        func onSearch(_ text: String) async {
            photos.removeAll()
            paginationController.resetWithNewSearchTerm(text)
            await loadNextPage(replacePhotos: true)
        }
        
        func onPaginate() async {
            await loadNextPage()
        }
        
        // MARK: - Private
        
        private func loadNextPage(replacePhotos: Bool = false) async {
            state = .loading
            
            do {
                let photosDTO = try await Task { [paginationController] in
                    try await paginationController.loadNextPage()
                }.value
                
                let photos = createViewModels(from: photosDTO)
                
                if replacePhotos {
                    self.photos = photos
                } else {
                    self.photos.append(contentsOf: photos)
                }
                state = paginationController.isNextPageAvailable() ? .idle : .allPagesLoaded
            } catch {
                let metadata = ErrorMetadata(error: error)                
                state = .error(metadata.message)
                metadata.source == .api ? showPopupError(metadata.message) : ()
            }
        }
        
        private func createViewModels(from models: [PhotoDTO]) -> [PhotoItemView.ViewModel] {
            models.map { photo in
                PhotoItemView.ViewModel(photo: photo) { [weak self] in
                    self?.deletePhoto(photo)
                }
            }
        }
        
        private func deletePhoto(_ photo: PhotoDTO) {
            let index = photos.firstIndex { $0.photoId == photo.id }
            
            if let index {
                photos.remove(at: index)
            }
        }
        
        // MARK: Error handling
        
        private func showPopupError(_ error: String) {
            print("Popup error: \(error)")
        }
    }
}

extension MainListView.ViewModel {
    enum State: Equatable {
        case loading
        case idle
        case allPagesLoaded
        case error(String)
    }
}
