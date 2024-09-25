//
//  ServiceLocatorTest.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 25.09.2024.
//

import XCTest
@testable import Flickr

final class ServiceLocatorTest: XCTestCase {
    override func tearDown() {
        ServiceContainer.unregisterAll()
    }
    
    func testRegisterAndResolveSingleton() throws {
        ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())
        @ServiceLocator(.singleton) var service1: MockServiceProtocol
        @ServiceLocator(.singleton) var service2: MockServiceProtocol
        
        XCTAssertTrue(service1 === service2, "Singleton services should return the same instance")
    }
    
    func testRegisterAndResolveNewInstance() throws {
        ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())
        @ServiceLocator(.new) var service1: MockServiceProtocol
        @ServiceLocator(.new) var service2: MockServiceProtocol
        
        XCTAssertFalse(service1 === service2, "New services should return different instances each time")
    }
    
    func testTreadSafetyRegisterAndResolve() async throws {
        ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            // IMPORTANT: "Service must be resolved before the test"
            for _ in 1...100 {
                group.addTask {
                    ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())
                }
                
                group.addTask {
                    let service: MockServiceProtocol = try ServiceContainer.resolve(lifetime: .singleton)
                    XCTAssertTrue(service is MockService1, "Service `\(service)` should be an instance of `\(MockService1.self)`")
                }
            }
            
            try await group.waitForAll()
        }
    }
}
