//
//  FlickrSearchPaginationController.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import Foundation

protocol FlickrSearchPaginationController {
    var page: Int { get }
    var searchTerm: String { get }
    
    func isNextPageAvailable() -> Bool
    func loadNextPage() async throws -> [PhotoDTO]
    func resetPages()
    func resetWithNewSearchTerm(_ searchTerm: String)
}

final class FlickrSearchPaginationControllerDefault: FlickrSearchPaginationController {
    @ServiceLocator private var flickrService: FlickrService
    private let perPage: Int
    private var totalPages: Int?
    private(set) var page = 0
    private(set) var searchTerm = ""
    
    /// Lock date to time when first page was loaded.
    /// This will avoid duplicating photos in next pages when new photo was added on the server
    private var maxUploadDate = Date()
    
    init(perPage: Int = 20) {
        self.perPage = perPage
    }
    
    func isNextPageAvailable() -> Bool {
        guard let totalPages else { return true }
        return page < totalPages
    }
    
    func loadNextPage() async throws -> [PhotoDTO] {
        let pageResponse = try await flickrService.search(
            for: searchTerm,
            page: page + 1,
            perPage: perPage,
            maxUploadDate: maxUploadDate
        )
        page = pageResponse.page
        totalPages = pageResponse.pages
        return pageResponse.photo
    }
    
    func resetPages() {
        page = 0
        totalPages = nil
        maxUploadDate = Date()
    }
    
    func resetWithNewSearchTerm(_ searchTerm: String) {
        resetPages()
        self.searchTerm = searchTerm
    }
}
