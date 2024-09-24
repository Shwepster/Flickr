//
//  FlickrDTO.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

struct PhotosResponseDTO: Codable {
    let photos: PageDTO?
    let stat: String
    let code: Int?
}

struct PageDTO: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoDTO]
}

struct PhotoDTO: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String?
}

// MARK: - Equatable

extension PhotoDTO: Equatable {
    static func == (lhs: PhotoDTO, rhs: PhotoDTO) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Equatable

extension PageDTO: Equatable {
    static func == (lhs: PageDTO, rhs: PageDTO) -> Bool {
        lhs.page == rhs.page
        && lhs.pages == rhs.pages
        && lhs.perpage == rhs.perpage
        && lhs.total == rhs.total
        && lhs.photo == rhs.photo
    }
}
