//
//  FlickrError.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

enum FlickrError: Error, Equatable {
    init(code: Int) {
        switch code {
            case 0: self = .noData
            case 100: self = .invalidApiKey
            case 116: self = .badUrl
            case 105: self = .serviceUnavailable
            case 106: self = .searchUnavailable
            default: self = .invalidStatusCode(code)
        }
    }
    
    // Flickr API errors: https://www.flickr.com/services/api/flickr.photos.search.htm
    case invalidApiKey
    case badUrl
    case serviceUnavailable
    case searchUnavailable
    // Custom errors
    case noData
    case invalidStatusCode(Int)
    
    var code: Int {
        switch self {
            case .noData: return 0
            case .invalidApiKey: return 100
            case .badUrl: return 116
            case .serviceUnavailable: return 105
            case .searchUnavailable: return 106
            case .invalidStatusCode(let code): return code
        }
    }
}
