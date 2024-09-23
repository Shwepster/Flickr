//
//  PhotoDTOMock.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 23.09.2024.
//

@testable import Flickr

extension PhotoDTO {
    static var mock: PhotoDTO {
        PhotoDTO(
            id: "1",
            owner: "test",
            secret: "test",
            server: "test",
            title: "test"
        )
    }
}
