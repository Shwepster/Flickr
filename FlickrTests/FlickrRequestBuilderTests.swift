//
//  FlickrRequestBuilderTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 24.09.2024.
//

import XCTest
@testable import Flickr

final class FlickrRequestBuilderTests: XCTestCase {
    private var builder: FlickrRequestBuilder!
    private let key = "flickr_key"
    
    override func setUp() {
        builder = .init(key: key)
    }
    
    override func tearDown() {
        builder = nil
    }
    
    // MARK: - Tests
    
    func testImageRequest() {
        let id = "image_id"
        let serverId = "server_id"
        let secret = "secret_key"
        let size = PhotoSize.b.rawValue
        let expectedURL = URL(
            string: "https://live.staticflickr.com/\(serverId)/\(id)_\(secret)_\(size).jpg"
        )!

        let request = builder.image(id: id, serverId: serverId, secret: secret, size: size)
        XCTAssertNotNil(request.url, "Request URL should not be nil")
        XCTAssertEqual(request.url, expectedURL, "The constructed URL should match the expected URL")
    }
    
    func testSearchRequest() {
        testSearchRequest(searchTerm: "search_term")
    }
    
    func testSearchEmptyRequest() {
        testSearchRequest(searchTerm: "")
    }
    
    // MARK: - Helpers
    
    private func testSearchRequest(searchTerm: String) {
        let page = 1
        let perPage = 10
        let date = Date()
        let expectedURL = URL(
            string: "https://api.flickr.com/services/rest/"
            + "?method=flickr.photos.search&api_key=\(key)"
            + "&text=\(searchTerm)&page=\(page)&per_page=\(perPage)"
            + "&max_upload_date=\(Int(date.timeIntervalSince1970).description)"
            + "&format=json&nojsoncallback=1"
        )!
        
        let request = builder.search(query: searchTerm, page: page, perPage: perPage, maxUploadDate: date)
        XCTAssertNotNil(request.url, "Request URL should not be nil")
        XCTAssertEqual(request.url, expectedURL, "The constructed URL should match the expected URL")
    }
}
