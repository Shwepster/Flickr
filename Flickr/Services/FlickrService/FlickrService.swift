//
//  FlickrService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

protocol FlickrService: Sendable {
    func search(for query: String, page: Int, perPage: Int) async throws -> PageDTO
    func loadImageData(for photo: PhotoDTO, size: PhotoSize) async throws -> Data
}
