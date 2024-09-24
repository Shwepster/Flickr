//
//  FlickrServiceMock.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

import Foundation
import Synchronization
@testable import Flickr

final class FlickrServiceMock: FlickrService, @unchecked Sendable {
    var data: Data?
    var pageDTO: PageDTO?
    var error: MockError?
    var delay: TimeInterval = 0
    var failAfterRequestCount: Int?
    let requestCount: Atomic<Int> = .init(0)
    
    private func mockRequest<T>(returnObject: T?) async throws -> T {
        let count = requestCount.add(1, ordering: .acquiringAndReleasing).newValue
        if let failAfterRequestCount, count > failAfterRequestCount {
            throw MockError.noData
        }
        
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }
        
        try Task.checkCancellation()
        if let error { throw error }
        if let returnObject { return returnObject }
        
        throw MockError.noData
    }
    
    func search(for query: String, page: Int, perPage: Int) async throws -> PageDTO {
        try await mockRequest(returnObject: pageDTO)
    }
    
    func loadImageData(for photo: PhotoDTO, size: PhotoSize) async throws -> Data {
        try await mockRequest(returnObject: data)
    }
    
    func reset() {
        data = nil
        pageDTO = nil
        error = nil
        delay = 0
        failAfterRequestCount = nil
        requestCount.store(0, ordering: .sequentiallyConsistent)
    }
}

// MARK: - MockError

extension FlickrServiceMock {
    enum MockError: Error {
        case noData
        case other
    }
}
