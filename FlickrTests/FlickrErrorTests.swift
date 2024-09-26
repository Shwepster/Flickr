//
//  FlickrErrorTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import XCTest
@testable import Flickr

final class FlickrErrorTests: XCTestCase {
    func testErrorCodes() {
        validateThatError(code: 0, is: .noData)
        validateThatError(code: 100, is: .invalidApiKey)
        validateThatError(code: 116, is: .badUrl)
        validateThatError(code: 105, is: .serviceUnavailable)
        validateThatError(code: 106, is: .searchUnavailable)
        validateThatError(code: 50, is: .invalidStatusCode(50))
    }
    
    private func validateThatError(code: Int, is type: FlickrError) {
        let error = FlickrError(code: code)
        XCTAssertEqual(error, type, "\(error) is not \(type)")
        XCTAssertEqual(error.code, code, "\(error) has wrong code \(error.code), but should be \(code)")
    }
}
