//
//  ErrorMetadata.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 09.10.2024.
//

struct ErrorMetadata {
    enum Source {
        case api
        case user
        case authentication
    }
    
    let error: Error
    let source: Source
    let message: String
    
    init(error: Error) {
        self.error = error
        let (source, message) = Self.createMetadata(from: error)
        self.source = source
        self.message = message
    }
    
    private static func createMetadata(from error: Error) -> (source: Source, message: String) {
        switch error {
        case let error as HTTPError:
            return metadata(for: error)
        case let error as FlickrError:
            return metadata(for: error)
        default:
            return (.api, "Unknown error: \(error)")
        }
    }
    
    private static func metadata(for error: HTTPError) -> (source: Source, message: String) {
        switch error {
        case .notFound:
            return (.user, "No photos found")
        case .noPermission:
            return (.api, "No permission to access the API")
        case .invalidStatusCode, .unexpectedResponseType:
            return (.api, "Loading error: \(error)")
        }
    }
    
    private static func metadata(for error: FlickrError) -> (source: Source, message: String) {
        switch error {
        case .invalidApiKey:
            return (.authentication, "Invalid API key")
        case .badUrl:
            return (.api, "Bad URL")
        case .serviceUnavailable:
            return (.api, "Service unavailable")
        case .searchUnavailable:
            return (.api, "Search unavailable")
        case .noSearchTerm:
            return (.api, "No search term")
        case .noData:
            return (.api, "Nothing found")
        case .invalidStatusCode(let code):
            return (.api, "Invalid status code: \(code)")
        }
    }
}
