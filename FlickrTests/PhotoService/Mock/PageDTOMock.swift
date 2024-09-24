//
//  PageDTOMock.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 24.09.2024.
//

import Foundation
@testable import Flickr

extension PageDTO {
    static var empty: PageDTO {
        .init(page: 1, pages: 0, perpage: 1, total: 0, photo: [])
    }
    
    static var fullPage: PageDTO {
        .init(
            page: 1,
            pages: 1,
            perpage: 1,
            total: PhotoDTO.mocks.count,
            photo: PhotoDTO.mocks
        )
    }
    
    static var mock1: PageDTO {
        .init(
            page: 1,
            pages: 1,
            perpage: 1,
            total: 1,
            photo: [PhotoDTO.mock]
        )
    }
    
    static var mock2: PageDTO {
        .init(
            page: 1,
            pages: 1,
            perpage: 1,
            total: 1,
            photo: [PhotoDTO.mock2]
        )
    }
    
    static var mock3: PageDTO {
        .init(
            page: 1,
            pages: 1,
            perpage: 1,
            total: 1,
            photo: [PhotoDTO.mock3]
        )
    }
    
    static var mock4: PageDTO {
        .init(
            page: 1,
            pages: 1,
            perpage: 1,
            total: 1,
            photo: [PhotoDTO.mock4]
        )
    }
}
