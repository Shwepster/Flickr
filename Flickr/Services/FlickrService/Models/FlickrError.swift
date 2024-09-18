//
//  FlickrError.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

enum FlickrError: Error {
    init(code: Int) {
        switch code {
            case 100: self = .invalidApiKey
            case 116: self = .badUrl
            case 105: self = .serviceUnavailable
            case 106: self = .searchUnavailable
            default: self = .invalidStatusCode(code)
        }
    }
    
    case noData
    case invalidApiKey
    case badUrl
    case serviceUnavailable
    case searchUnavailable
    case invalidStatusCode(Int)
}
