//
//  AppSettings.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

struct AppSettings {
    static let photosPerPage = 10
    static let photoSize = PhotoSize.b
    static var croppSize: CGSize {
        .init(width: 350, height: 350)
    }
}
