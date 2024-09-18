//
//  FlickrRequestBuilder.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

struct FlickrRequestBuilder {
    private let key: String
    private let format = "json"
    
    init(key: String) {
        self.key = key
    }
    
    func search(query: String, page: Int, perPage: Int) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = [
            .init(name: "method", value: "flickr.photos.search"),
            .init(name: "api_key", value: key),
            .init(name: "text", value: query),
            .init(name: "page", value: String(page)),
            .init(name: "per_page", value: String(perPage)),
            .init(name: "format", value: format),
            .init(name: "nojsoncallback", value: "1")
        ]
        
        return URLRequest(url: components.url!)
    }
    
    func image(id: String, serverId: String, secret: String, size: String) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "live.staticflickr.com"
        components.path = "/\(serverId)/\(id)_\(secret)_\(size).jpg"
        return URLRequest(url: components.url!)
    }
}
