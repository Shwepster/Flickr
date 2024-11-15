//
//  HTTPClient.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import Foundation

final class HTTPClient: @unchecked Sendable {
    private let session: URLSessionProtocol
    private let logResponse: Bool
    
    init(session: URLSessionProtocol = URLSession.shared, logResponse: Bool = false) {
        self.session = session
        self.logResponse = logResponse
    }
    
    // MARK: - Public
    
    func request(_ url: URLRequest) async throws -> Data {        
        let (data, response) = try await session.data(for: url)
        
        try Task.checkCancellation()

        guard let response = response as? HTTPURLResponse else {
            throw HTTPError.unexpectedResponseType
        }
        
        try checkResponseStatus(response)
        
        if logResponse {
            print("---")
            print("Request: \(response.url?.absoluteString ?? "")")
            print("---")
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            print("---")
        }
        
        return data
    }
    
    // MARK: - Private
    
    private func checkResponseStatus(_ response: HTTPURLResponse) throws {
        if response.statusCode == 401 {
            throw HTTPError.noPermission
        }
        
        if response.statusCode == 404 {
            throw HTTPError.notFound
        }
        
        if response.statusCode < 200 || response.statusCode >= 300 {
            throw HTTPError.invalidStatusCode(response.statusCode)
        }
    }
}
