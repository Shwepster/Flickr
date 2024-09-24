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
    
    static var mock2: PhotoDTO {
        PhotoDTO(
            id: "2",
            owner: "test",
            secret: "test",
            server: "test",
            title: "test"
        )
    }
    
    static var mock3: PhotoDTO {
        PhotoDTO(
            id: "3",
            owner: "test",
            secret: "test",
            server: "test",
            title: "test"
        )
    }
    
    static var mock4: PhotoDTO {
        PhotoDTO(
            id: "4",
            owner: "test",
            secret: "test",
            server: "test",
            title: "test"
        )
    }
    
    static var mock5: PhotoDTO {
        PhotoDTO(
            id: "5",
            owner: "test",
            secret: "test",
            server: "test",
            title: "test"
        )
    }
    
    static var mocks: [PhotoDTO] {
        [mock, mock2, mock3, mock4, mock5]
    }
}
