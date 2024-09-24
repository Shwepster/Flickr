//
//  FlickrServiceDefaultTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 24.09.2024.
//

import XCTest
@testable import Flickr

final class FlickrServiceDefaultTests: XCTestCase {
    private var service: FlickrServiceDefault!
    private var urlSession: URLSessionMock!
    private var image: UIImage { SharedTestData.image }
    
    override func setUp() {
        urlSession = .init()
        let client = HTTPClient(session: urlSession, logResponse: true)
        service = .init(httpClient: client, requestBuilder: .init(key: "test_key"))
    }
    
    override func tearDown() {
        urlSession.reset()
        urlSession = nil
        service = nil
    }
    
    // MARK: - ImageLoading
    
    func testLoadingImageSuccess() async {
        urlSession.setResponseCode(200)
        urlSession.setData(image.pngData()!)
        
        do {
            let imageData = try await service.loadImageData(for: .mock, size: .b)
            XCTAssertEqual(imageData, image.pngData())
        } catch {
            XCTFail("Loading image failed: \(error.localizedDescription)")
        }
    }
    
    func testLoadingImageFailure() async {
        urlSession.setResponseCode(404) // can set any other error
        urlSession.setData(image.pngData()!)
        
        do {
            _ = try await service.loadImageData(for: .mock, size: .b)
            XCTFail("Expected failure, but image loading succeeded with a 404 response")
        } catch {
            XCTAssertEqual(
                error as? HTTPError,
                .notFound,
                "Received error is not a 404 error: \(error.localizedDescription)"
            )
        }
    }
    
    func testLoadingImageCancel() async {
        let delay = 0.3
        urlSession.setResponseCode(200)
        urlSession.setData(image.pngData()!)
        urlSession.setRequestDelayTime(delay)
        
        let task = Task<Data, Error> { [service] in
            try await service!.loadImageData(for: .mock, size: .b)
        }
        
        do {
            try await Task.sleep(for: .seconds(delay/2))
            task.cancel()
            
            let _ = try await task.value
            XCTFail("Loading image succeeded")
        } catch {
            XCTAssertTrue(error is CancellationError, "Error is not a cancellation error")
        }
    }
    
    // MARK: - Searching
    
    func testSearchFullPage() async {
        let response = PhotosResponseDTO.fullPage
        configureSession(with: response, code: 200)
        await searchWithExpectedSuccess(expectedResponse: response)
    }
    
    func testSearchEmptyPage() async {
        let response = PhotosResponseDTO.okResponse(withPage: .empty)
        configureSession(with: response, code: 200)
        await searchWithExpectedSuccess(expectedResponse: response)
    }
    
    func testSearchNilPage() async {
        configureSession(with: .okResponse(withPage: nil), code: 200)
        await searchWithExpectedError(FlickrError.noData)
    }
    
    // MARK: Failed response
    
    func testSearchFlickrErrorWithEmptyResponse() async {
        configureSession(with: .failedResponse(withError: .searchUnavailable, page: .empty), code: 200)
        await searchWithExpectedError(FlickrError.searchUnavailable)
    }
    
    func testSearchFlickrErrorWithNilResponse() async {
        configureSession(with: .failedResponse(withError: .noData, page: .empty), code: 200)
        await searchWithExpectedError(FlickrError.noData)
    }
    
    func testSearchWithAuthError() async {
        configureSession(with: .fullPage, code: 401)
        await searchWithExpectedError(HTTPError.noPermission)
    }
    
    func testSearchWithCorruptedResponse() async {
        urlSession.setResponse(URLResponse(), data: Data())
        await searchWithExpectedError(HTTPError.unexpectedResponseType)
    }
    
    func testCancelSearch() async {
        configureSession(with: .fullPage, code: 200)
        let delay = 0.3
        urlSession.setRequestDelayTime(delay)
        
        let task = Task<PageDTO, Error> { [service] in
            try await service!.search(for: "test", page: 1, perPage: 1)
        }
        
        do {
            try await Task.sleep(for: .seconds(delay/2))
            task.cancel()
            
            let _ = try await task.value
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is CancellationError, "Error should be a CancellationError, but was \(error)")
        }
    }
    
    // MARK: - Helper
    
    private func configureSession(with response: PhotosResponseDTO, code: Int) {
        urlSession.setResponseCode(code)
        urlSession.setData(encodeResponse(response))
    }
    
    private func searchWithExpectedSuccess(expectedResponse: PhotosResponseDTO) async {
        do {
            let result = try await service.search(for: "test", page: 1, perPage: 1)
            XCTAssertEqual(result, expectedResponse.photos)
        } catch {
            XCTFail("Search failed with error: \(error)")
        }
    }
    
    private func searchWithExpectedError<T: Error>(_ expectedError: T) async where T: Equatable {
        do {
            let _ = try await service.search(for: "test", page: 1, perPage: 1)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(
                error as? T,
                expectedError,
                "Search must fail with \(expectedError.localizedDescription), but got: \(error.localizedDescription)"
            )
        }
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
