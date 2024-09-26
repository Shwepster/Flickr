//
//  FlickrSearchPaginator.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import Foundation

final class FlickrSearchPaginator {
    @ServiceLocator private var flickrService: FlickrService
    private let perPage: Int
    private(set) var page: Int = 0
    private(set) var searchTerm: String = ""
    private var totalPages: Int?
    @Published private(set) var isLoading: Bool = false
    
    init(perPage: Int = 20) {
        self.perPage = perPage
    }
    
    func isNextPage() -> Bool {
        guard let totalPages else { return true }
        return page < totalPages
    }
    
    func loadNextPage() async throws -> [PhotoDTO] {
        guard !isLoading, isNextPage() else { return [] }
        isLoading = true
        defer { isLoading = false }
        
        let pageResponse = try await flickrService.search(
            for: searchTerm,
            page: page + 1,
            perPage: perPage
        )
        page = pageResponse.page
        totalPages = pageResponse.pages
        return pageResponse.photo
    }
    
    func resetPages() {
        page = 0
        totalPages = nil
    }
    
    func resetWithSearchTerm(_ searchTerm: String) {
        resetPages()
        self.searchTerm = searchTerm
    }
}
