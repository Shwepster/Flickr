//
//  PhotoListViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 28.10.2024.
//

import SwiftUI

@MainActor
class PhotoListViewModel: ObservableObject {
    @Published var photoViewModels: [PhotoItemView.ViewModel] = []
    @Published var state: State = .idle
    @Published var errorModel = ErrorModel()
    @Published var navigation: NavigationType?
    private let paginationController: FlickrSearchPaginationController
    private let photoMapper = PhotoModelMapper()
    @ServiceLocator(.singleton) private var photoStorage: PhotoStorage
    private var updateStream: Task<Void, Never>?
    
    init(paginationController: FlickrSearchPaginationController = FlickrSearchPaginationControllerDefault(
        perPage: AppSettings.photosPerPage
    )) {
        self.paginationController = paginationController
    }
    
    func onCreate() async {
        setupBinding()
        // manually send event to init with current photos
        await handlePhotoUpdateEvent(.replace(photoStorage.photos))
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
    
    // MARK: For override
    func deletePhoto(viewModel: PhotoItemView.ViewModel) {
        guard let index = photoViewModels.firstIndex(of: viewModel) else { return }
        let model = photoViewModels.remove(at: index)
        Task {
            await photoStorage.removePhoto(model.photo)
        }
    }
    
    /// Factory method
    /// - Parameter models: Models to be mapped
    /// - Returns: View models for items
    func createViewModels(from models: [PhotoModel]) -> [PhotoItemView.ViewModel] {
        fatalError("createViewModels(from:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setupBinding() {
        updateStream = Task {
            let updateStream = await photoStorage.observePhotoUpdates()
            
            for await event in updateStream {
                handlePhotoUpdateEvent(event)
            }
        }
    }
    
    private func loadNextPage(replacePhotos: Bool = false) async {
        state = .loading
        
        do {
            let photosDTO = try await Task { [paginationController] in
                try await paginationController.loadNextPage()
            }.value
            
            let photos = await photoMapper.map(photosDTO)
            if replacePhotos {
                await photoStorage.replacePhotos(with: photos)
            } else {
                await photoStorage.addPhotos(photos)
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
    
    private func handlePhotoUpdateEvent(_ event: PhotoStorage.UpdateEvent) {
        switch event {
        case .replace(let photos):
            let viewModels = createViewModels(from: photos)
            photoViewModels = viewModels
        case .append(let photos):
            let viewModels = createViewModels(from: photos)
            photoViewModels.append(contentsOf: viewModels)
        case .update(let photo):
            for viewModel in photoViewModels where viewModel.photo == photo {
                viewModel.updatePhoto(photo)
            }
        case .remove(let photo):
            photoViewModels.removeAll { $0.photo == photo }
        }
    }
}
