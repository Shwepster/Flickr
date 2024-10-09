//
//  FlickrSearchPaginationControllerMock.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 09.10.2024.
//

import Foundation

@testable import Flickr
final class FlickrSearchPaginationControllerMock {
    // mock
    var photos: [Flickr.PhotoDTO] = []
    var isNextPage: Bool = true
    var error: Error?
    var timeout: TimeInterval = 0
    
    // protocol
    var page: Int = 0
    var searchTerm: String = ""
    
    func resetMock() {
        photos.removeAll()
        isNextPage = false
        error = nil
        timeout = 0
    }
}

// MARK: - FlickrSearchPaginationController

extension FlickrSearchPaginationControllerMock: FlickrSearchPaginationController {
    func isNextPageAvailable() -> Bool {
        isNextPage
    }
    
    func loadNextPage() async throws -> [Flickr.PhotoDTO] {
        try await Task.sleep(for: .seconds(timeout))
        
        if let error {
            throw error
        } else {
            return photos
        }
    }
    
    func resetPages() {
        page = 0
    }
    
    func resetWithNewSearchTerm(_ searchTerm: String) {
        resetPages()
        self.searchTerm = searchTerm
    }
}
