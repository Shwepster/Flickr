//
//  MockService.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 25.09.2024.
//

import Foundation

protocol MockServiceProtocol: AnyObject, Sendable {}
final class MockService1: MockServiceProtocol {}
final class MockService2: MockServiceProtocol {}
