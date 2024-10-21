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
        @Published var photoViewModels: [PhotoItemView.ViewModel] = []
        @Published var state: State = .idle
        @Published var editingViewModel: PhotoItemView.ViewModel?
        @Published var pageViewModel: PageView.ViewModel?
        @Published var errorModel = ErrorModel()
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
            photoViewModels.removeAll()
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
                    self.photoViewModels = photos
                } else {
                    self.photoViewModels.append(contentsOf: photos)
                }
                state = paginationController.isNextPageAvailable() ? .idle : .allPagesLoaded
            } catch {
                let metadata = ErrorMetadata(error: error)                
                state = .error(metadata.message)
                
                if metadata.source == .authentication {
                    errorModel.presentError(metadata.message)
                }
            }
        }
        
        private func createViewModels(from models: [PhotoDTO]) -> [PhotoItemView.ViewModel] {
            models.map { photo in
                PhotoItemView.ViewModel(photo: photo) { [weak self] viewModel in
                    self?.deletePhoto(viewModel: viewModel)
                } onEdit: { [weak self] viewModel in
                    self?.editingViewModel = viewModel
                } onSelect: { [weak self] viewModel in
                    guard let self else { return }
                    pageViewModel = .init(initialPhoto: viewModel, photos: photoViewModels) { selectedViewModel in
                        self.pageViewModel = nil
                        self.editingViewModel = selectedViewModel
                    }
                }
            }
        }
        
        private func deletePhoto(viewModel: PhotoItemView.ViewModel) {
            photoViewModels.removeAll { $0 == viewModel }
        }
    }
}
