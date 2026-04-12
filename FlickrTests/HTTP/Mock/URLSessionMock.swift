//
//  URLSessionMock.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 20.09.2024.
//

import Foundation
@testable import Flickr

final class URLSessionMock: URLSessionProtocol {
    /// In seconds
    private var requestDelayTime: TimeInterval = 0
    private var response: URLResponse = .init()
    private var data: Data = .init()
    
    func data(for url: URLRequest) async throws -> (Data, URLResponse) {
        try await Task.sleep(for: .seconds(requestDelayTime))
        return (data, response)
    }
    
    // MARK: - Setup
    
    func setResponseCode(_ code: Int) {
        response = HTTPURLResponse(
            url: .init(string: "https://example.com")!,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    func setData(_ data: Data) {
        self.data = data
    }
    
    func setResponse(_ response: URLResponse, data: Data) {
        self.response = response
        self.data = data
    }
    
    func setRequestDelayTime(_ time: TimeInterval) {
        requestDelayTime = time
    }
    
    func reset() {
        data = .init()
        response = .init()
        requestDelayTime = 0
    }
}
