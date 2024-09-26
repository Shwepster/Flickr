//
//  FlickrError.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

enum FlickrError: Error, Equatable {
    init(code: Int) {
        switch code {
        case FlickrError.noData.code:
            self = .noData
        case FlickrError.invalidApiKey.code:
            self = .invalidApiKey
        case FlickrError.badUrl.code:
            self = .badUrl
        case FlickrError.serviceUnavailable.code:
            self = .serviceUnavailable
        case FlickrError.searchUnavailable.code:
            self = .searchUnavailable
        case FlickrError.noSearchTerm.code:
            self = .noSearchTerm
        default:
            self = .invalidStatusCode(code)
        }
    }
    
    // Flickr API errors: https://www.flickr.com/services/api/flickr.photos.search.htm
    case invalidApiKey
    case badUrl
    case serviceUnavailable
    case searchUnavailable
    case noSearchTerm
    // Custom errors
    case noData
    case invalidStatusCode(Int)
    
    var code: Int {
        switch self {
        case .noData: return 0
        case .noSearchTerm: return 3
        case .invalidApiKey: return 100
        case .badUrl: return 116
        case .serviceUnavailable: return 105
        case .searchUnavailable: return 106
        case .invalidStatusCode(let code): return code
        }
    }
}
