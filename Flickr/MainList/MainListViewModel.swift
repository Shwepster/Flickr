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
        @Published var photos: [PhotoDTO] = []
        @Published var state: State = .idle
        @Published var allPagesLoaded = false
        @Published var backgroundError: String?
        @Published var footerError: String?
        // popup error
        private let paginator = FlickrSearchPaginator(perPage: AppSettings.photosPerPage)
        
        func refresh() async {
            await paginator.resetPages()
            await loadNextPage(replacePhotos: true)
        }
        
        func onSearch(_ text: String) async {
            photos.removeAll()
            await paginator.resetWithSearchTerm(text)
            await loadNextPage(replacePhotos: true)
        }
        
        func onPaginate() async {
            await loadNextPage()
        }
        
        private func loadNextPage(replacePhotos: Bool = false) async {
            state = .loading
            
            do {
                let photos = try await paginator.loadNextPage()
                if replacePhotos {
                    self.photos = photos
                } else {
                    self.photos.append(contentsOf: photos)
                }
                state = await paginator.isNextPageAvailable() ? .idle : .allPagesLoaded
            } catch {
                let metadata = ErrorMetadata(error: error)                
                state = .error(metadata.message)
            }
        }
        
        // MARK: Error handling
        
        private func setDisplayingError(_ error: String) {
            if photos.isEmpty {
                backgroundError = error
            } else {
                footerError = error
            }
        }
        
        private func showPopupError(_ error: String) {
            print("Popup error: \(error)")
        }
        
        private func handleError(_ error: Error) {
            let metadata = ErrorMetadata(error: error)
            
            switch metadata.source {
            case .api:
                print("Failed to fetch photos from Flickr API: \(metadata.error.localizedDescription)")
                setDisplayingError("Failed to fetch photos from Flickr")
            case .user:
                setDisplayingError(metadata.message)
            case .authentication:
                showPopupError(metadata.message)
            }
        }
    }
}

extension MainListView.ViewModel {
    enum State {
        case loading
        case idle
        case allPagesLoaded
        case error(String)
    }
}

struct ErrorMetadata {
    enum Source {
        case api
        case user
        case authentication
    }
    
    let error: Error
    let source: Source
    let message: String
    
    init(error: Error) {
        self.error = error
        let (source, message) = Self.handleError(error)
        self.source = source
        self.message = message
    }
    
    private static func handleError(_ error: Error) -> (source: Source, message: String) {
        switch error {
        case let error as HTTPError:
            return metadata(for: error)
        case let error as FlickrError:
            return metadata(for: error)
        default:
            return (.api, "Unknown error: \(error)")
        }
    }
    
    private static func metadata(for error: HTTPError) -> (source: Source, message: String) {
        switch error {
        case .notFound:
            return (.user, "No photos found")
        case .noPermission:
            return (.api, "No permission to access the API")
        case .invalidStatusCode, .unexpectedResponseType:
            return (.api, "Loading error: \(error)")
        }
    }
    
    private static func metadata(for error: FlickrError) -> (source: Source, message: String) {
        switch error {
        case .invalidApiKey:
            return (.authentication, "Invalid API key")
        case .badUrl:
            return (.api, "Bad URL")
        case .serviceUnavailable:
            return (.api, "Service unavailable")
        case .searchUnavailable:
            return (.api, "Search unavailable")
        case .noSearchTerm:
            return (.api, "No search term")
        case .noData:
            return (.api, "Nothing found")
        case .invalidStatusCode(let code):
            return (.api, "Invalid status code: \(code)")
        }
    }
}
