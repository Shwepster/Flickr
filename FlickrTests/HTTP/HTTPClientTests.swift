//
//  HTTPClientTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 20.09.2024.
//

import XCTest
@testable import Flickr

final class HTTPClientTests: XCTestCase {
    private var client: HTTPClient!
    private var urlSessionMock: URLSessionMock!
    private let mockRequest: URLRequest = .init(url: .init(string: "https://example.com")!)

    override func setUp() {
        urlSessionMock = URLSessionMock()
        client = HTTPClient(session: urlSessionMock)
    }
    
    override func tearDown() {
        urlSessionMock = nil
        client = nil
    }
    
    func testCancelRequest() async {
        urlSessionMock.setRequestDelayTime(1)
        
        let task = Task<Data, Error> { [client, mockRequest] in
            try await client!.request(mockRequest)
        }
        
        task.cancel()
        
        do {
            let _ = try await task.value
            XCTFail("Task should have been cancelled")
        } catch {
            XCTAssertTrue(task.isCancelled)
            XCTAssert(error is CancellationError, "\(error)")
        }
    }
    
    func testErrorInRequest() async {
        urlSessionMock.setResponseCode(404)
        
        await requestWithExpectedError(.notFound)
        
        urlSessionMock.reset()
        urlSessionMock.setResponseCode(401)
        
        await requestWithExpectedError(.noPermission)
        
        urlSessionMock.reset()
        urlSessionMock.setResponseCode(500)
        
        await requestWithExpectedError(.invalidStatusCode(500))
        
        urlSessionMock.reset()
        urlSessionMock.setResponse(.init(), data: .init())
        
        await requestWithExpectedError(.unexpectedResponseType)
    }
    
    func testSuccessfulRequests() async {
        guard let expectedData = "expected data".data(using: .utf8) else {
            XCTFail("Failed to encode string to data")
            return
        }

        urlSessionMock.setResponseCode(200)
        urlSessionMock.setData(expectedData)
        
        do {
            let data = try await client.request(mockRequest)
            XCTAssertEqual(data, expectedData)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: - Helpers
    
    func requestWithExpectedError(_ expectedError: HTTPError) async {
        do {
            let _ = try await client.request(mockRequest)
            XCTFail("Task should have failed")
        } catch {
            XCTAssert(error as? HTTPError == expectedError, "\(error)")
        }
    }
}
