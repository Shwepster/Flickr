//
//  FlickrDTO.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

struct PhotosResponseDTO: Decodable {
    let photos: PageDTO?
    let stat: String
    let code: Int?
}

struct PageDTO: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoDTO]
}

struct PhotoDTO: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String?
}
