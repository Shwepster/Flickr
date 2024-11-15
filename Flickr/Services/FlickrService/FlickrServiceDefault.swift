//
//  FlickrServiceDefault.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

import Foundation

final class FlickrServiceDefault: FlickrService {
    var key: String { requestBuilder.key }
    private let httpClient: HTTPClient
    private let requestBuilder: FlickrRequestBuilder
    private let decoder = JSONDecoder()
    
    init(httpClient: HTTPClient, requestBuilder: FlickrRequestBuilder) {
        self.httpClient = httpClient
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - Public
    
    func search(for query: String, page: Int, perPage: Int, maxUploadDate: Date) async throws -> PageDTO {
        let data = try await httpClient.request(
            requestBuilder.search(
                query: query,
                page: page,
                perPage: perPage,
                maxUploadDate: maxUploadDate
            )
        )
        
        try Task.checkCancellation()
        let model = try decoder.decode(PhotosResponseDTO.self, from: data)
        
        try checkFlickrResponseStatus(model)
        
        guard let page = model.photos else { throw FlickrError.noData }
        return page
    }
    
    func loadImageData(for photo: PhotoDTO, size: PhotoSize) async throws -> Data {        
        let data = try await httpClient.request(
            requestBuilder.image(
                id: photo.id,
                serverId: photo.server,
                secret: photo.secret,
                size: size.rawValue
            )
        )
        
        try Task.checkCancellation()
        return data
    }
    
    // MARK: - Private
    
    private func checkFlickrResponseStatus(_ response: PhotosResponseDTO) throws {
        if response.stat != "ok" {
            throw FlickrError(code: response.code ?? 0)
        }
    }
}
