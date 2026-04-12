//
//  URLSessionProtocol.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 20.09.2024.
//

import Foundation

protocol URLSessionProtocol {
    func data(for url: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    func data(for url: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: url, delegate: nil)
    }
}
