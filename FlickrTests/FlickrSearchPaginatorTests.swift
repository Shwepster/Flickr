//
//  FlickrSearchPaginatorTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import XCTest
@testable import Flickr

final class FlickrSearchPaginatorTests: XCTestCase {
    private var paginator: FlickrSearchPaginator!
    private var urlSession: URLSessionMock!
    private let pageSize = 10
    
    override func setUp() {
        urlSession = URLSessionMock()
        setupRealPaginator()
    }
    
    private func setupRealPaginator() {
        AppServicesRegistrator.registerAllServices()
        paginator = FlickrSearchPaginator(perPage: pageSize)
    }
    
    private func setupMockPaginator() {
        let flickrService = FlickrServiceDefault(
            httpClient: .init(session: urlSession),
            requestBuilder: .init(key: "test_key")
        )
        ServiceContainer.register(FlickrService.self) { flickrService }
        paginator = FlickrSearchPaginator(perPage: pageSize)
    }
    
    override func tearDown() {
        paginator = nil
        urlSession = nil
        AppServicesRegistrator.unregisterAllServices()
    }

    func testLoadingNextPage() async throws {
        paginator.resetWithSearchTerm("cat")
        let result = try await paginator.loadNextPage()
        
        XCTAssertEqual(paginator.page, 1, "Page should be incremented")
        XCTAssertEqual(result.count, pageSize, "Page should contain 10 photos")
    }
    
    func testLoadingTwoPages() async throws {
        paginator.resetWithSearchTerm("cat")
        let result1 = try await paginator.loadNextPage()
        let result2 = try await paginator.loadNextPage()
        
        XCTAssertEqual(paginator.page, 2, "Page should be incremented two times")
        XCTAssertEqual(result1.count, pageSize, "Page 1 should contain 10 photos")
        XCTAssertEqual(result2.count, pageSize, "Page 2 should contain 10 photos")
        XCTAssertNotEqual(result1.first?.id, result2.first?.id, "Photos should be different")
    }
    
    func testPagesReset() async throws {
        paginator.resetWithSearchTerm("cat")
        
        let result1 = try await paginator.loadNextPage()
        let _       = try await paginator.loadNextPage()
        
        paginator.resetPages()
        XCTAssertEqual(paginator.page, 0, "Page should be reset to 0")
        
        let result2 = try await paginator.loadNextPage()
        XCTAssertEqual(result1.first?.id, result2.first?.id, "Photos should same")
    }
    
    func testSearchTermChange() async throws {
        paginator.resetWithSearchTerm("cat")
        let result1 = try await paginator.loadNextPage()
        
        paginator.resetWithSearchTerm("dog")
        XCTAssertEqual(paginator.page, 0, "Page should be reset to 0")
       
        let result2 = try await paginator.loadNextPage()
        XCTAssertNotEqual(result1.first?.id, result2.first?.id, "Photos should be different")
    }
    
    func testLoadingWithoutSearchTerm() async {
        await loadNextWithExpectedError(FlickrError.noSearchTerm)
        
        do {
            let _ = try await paginator.loadNextPage()
            XCTFail("Error should be thrown")
        } catch {
            if case FlickrError.noSearchTerm = error {
                return
            } else {
                XCTFail("Error should be of type `FlickrError.noSearchTerm`, but got `\(error)`")
            }
        }
    }
    
    func testHTTPErrors() async {
        setupMockPaginator()
        
        await loadNextWithExpectedError(responseCode: 401, expectedError: HTTPError.noPermission)
        await loadNextWithExpectedError(responseCode: 404, expectedError: HTTPError.notFound)
        await loadNextWithExpectedError(responseCode: 500, expectedError: HTTPError.invalidStatusCode(500))
    }
    
    func testFlickrErrors() async {
        setupMockPaginator()
        
        await loadNextWithFlickrError(.badUrl)
        await loadNextWithFlickrError(.searchUnavailable)
        await loadNextWithFlickrError(.serviceUnavailable)
        await loadNextWithFlickrError(.invalidApiKey)
        await loadNextWithFlickrError(.invalidStatusCode(20))
        await loadNextWithFlickrError(.noSearchTerm)
        await loadNextWithFlickrError(.noData)
    }
    
    // MARK: - Helpers
    
    private func loadNextWithExpectedError<T: Error>(
        responseCode: Int,
        expectedError: T
    ) async where T: Equatable {
        urlSession.setResponseCode(responseCode)
        await loadNextWithExpectedError(expectedError)
    }
    
    private func loadNextWithFlickrError(_ error: FlickrError) async {
        configureSession(with: .failedResponse(withError: error, page: nil), code: 200)
        await loadNextWithExpectedError(error)
    }
    
    private func loadNextWithExpectedError<T: Error>(_ expectedError: T) async where T: Equatable {
        do {
            let _ = try await paginator.loadNextPage()
            XCTFail("Should have thrown an error: \(expectedError)")
        } catch {
            XCTAssertEqual(
                error as? T,
                expectedError,
                "Loading must fail with \(expectedError), but got: \(error)"
            )
        }
    }
    
    private func configureSession(with response: PhotosResponseDTO, code: Int) {
        urlSession.setResponseCode(code)
        urlSession.setData(encodeResponse(response))
    }
    
    private func encodeResponse(_ response: PhotosResponseDTO) -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        if let data = try? encoder.encode(response) {
            return data
        }
        
        XCTFail("Failed to encode response")
        return Data()
    }
}
