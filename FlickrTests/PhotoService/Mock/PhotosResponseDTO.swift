//
//  File.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 24.09.2024.
//

import Foundation
@testable import Flickr

extension PhotosResponseDTO {
    static var fullPage: PhotosResponseDTO {
        .init(photos: .fullPage, stat: "ok", code: 200)
    }
    
    static func okResponse(withPage page: PageDTO?) -> PhotosResponseDTO {
        .init(photos: page, stat: "ok", code: 200)
    }
    
    static func failedResponse(withError error: FlickrError, page: PageDTO?) -> PhotosResponseDTO {
        .init(photos: page, stat: "fail", code: error.code)
    }
}
