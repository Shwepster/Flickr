//
//  PhotoSize.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

enum PhotoSize: String {
    case q // thumbnail
    case m
    case b
    
    var cgSize: CGSize {
        switch self {
            case .q: return .init(width: 100, height: 100)
            case .m: return .init(width: 240, height: 240)
            case .b: return .init(width: 480, height: 480)
        }
    }
}
