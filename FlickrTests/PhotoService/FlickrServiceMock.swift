//
//  FlickrServiceMock.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

import Foundation
@testable import Flickr

final class FlickrServiceMock: FlickrService, @unchecked Sendable {
    var data: Data?
    var pageDTO: PageDTO?
    var error: MockError?
    
    func search(for query: String, page: Int, perPage: Int) async throws -> PageDTO {
        if let error { throw error }
        
        if let pageDTO { return pageDTO }
        
        throw MockError.noData
    }
    
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async throws -> Data {
        if let error { throw error }
        
        if let data { return data }
        
        throw MockError.noData
    }
    
    func reset() {
        data = nil
        pageDTO = nil
        error = nil
    }
}

// MARK: - MockError

extension FlickrServiceMock {
    enum MockError: Error {
        case noData
        case noPage
        case other
    }
}
