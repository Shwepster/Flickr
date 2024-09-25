//
//  ServiceContainerTests.swift
//  FlickrTests
//
//  Created by Maxim Vynnyk on 25.09.2024.
//

import XCTest
@testable import Flickr

final class ServiceContainerTests: XCTestCase {
    override func tearDown() {
        ServiceContainer.unregisterAll()
    }
    
    func testRegisterAndResolveSingleton() throws {
        ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())
        
        let service1: MockServiceProtocol = try ServiceContainer.resolve(lifetime: .singleton)
        let service2: MockServiceProtocol = try ServiceContainer.resolve(lifetime: .singleton)
        XCTAssertTrue(service1 === service2, "Singleton services should return the same instance")
    }
    
    func testRegisterAndResolveNewInstance() throws {
        ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())
        
        let service1: MockServiceProtocol = try ServiceContainer.resolve(lifetime: .new)
        let service2: MockServiceProtocol = try ServiceContainer.resolve(lifetime: .new)
        
        XCTAssertFalse(service1 === service2, "New services should return different instances each time")
    }
    
    func testClosureFactoryRegistration() throws {
        ServiceContainer.register(MockServiceProtocol.self) { MockService1() }
        assertResolve(MockServiceProtocol.self, as: MockService1.self)
    }
    
    func testUnregisteredServiceResolution() throws {
        assertResolveFails(MockServiceProtocol.self)
    }

    func testRegisteringServiceDependingOnOtherService() throws {
        ServiceContainer.register(MockService1.self) { MockService1() }
        ServiceContainer.register(MockService2.self) { MockService2() }
        
        ServiceContainer.register(MockServiceProtocol.self) {
            do {
                let service1: MockService1 = try ServiceContainer.resolve(lifetime: .singleton)
                let _: MockService2 = try ServiceContainer.resolve(lifetime: .singleton)
                return service1 as MockServiceProtocol
            } catch {
                XCTFail("Unexpected error: \(error)")
                return MockService2()
            }
        }
        
        assertResolve(MockServiceProtocol.self, as: MockService1.self)
    }
    
    func testChangingRegisteredService() throws {
        try registerAndResolve(MockServiceProtocol.self, instance: MockService1())
        try registerAndResolve(MockServiceProtocol.self, instance: MockService2())
    }
    
    func testUnregisteringAllServices() throws {
        try registerAndResolve(MockServiceProtocol.self, instance: MockService1())
        try registerAndResolve(MockService1.self, instance: MockService1())
        try registerAndResolve(MockService2.self, instance: MockService2())
        
        ServiceContainer.unregisterAll()
        
        assertResolveFails(MockServiceProtocol.self)
        assertResolveFails(MockService1.self)
        assertResolveFails(MockService2.self)
    }
    
    func testTreadSafetyRegisterAndResolve() async throws {
        ServiceContainer.register(MockServiceProtocol.self, factory: MockService1())

        try await withThrowingTaskGroup(of: Void.self) { group in
            XCTAssertNoThrow(
                try ServiceContainer.resolve(MockServiceProtocol.self, lifetime: .singleton),
                "Service must be resolved before the test"
            )
            
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
    
    // MARK: - Helpers
    
    private func assertResolve<T: Sendable, S: Sendable>(_ registeredType: T.Type, as type: S.Type) {
        do {
            let service: T = try ServiceContainer.resolve(lifetime: .singleton)
            XCTAssertTrue(service is S, "Service `\(service)` should be an instance of `\(S.self)`")
        } catch {
            XCTFail("Failed to resolve service \(registeredType): \(error)")
        }
    }
    
    private func registerAndResolve<T: Sendable, S: Sendable>(_ targetType: T.Type, instance: S) throws {
        guard let instance = instance as? T else {
            XCTFail("Instance `\(S.self)` should be castable to `\(targetType)`")
            throw ServiceContainer.ResolveError
                .unableToInitializeService("Failed to cast instance `\(S.self)` to `\(targetType)")
        }
        
        ServiceContainer.register(targetType) { instance }
        assertResolve(targetType, as: S.self)
    }
    
    private func assertResolveFails<T: Sendable>(_ targetType: T.Type) {
        XCTAssertThrowsError(try ServiceContainer.resolve(targetType, lifetime: .singleton)) { error in
            if case .unableToInitializeService = error as? ServiceContainer.ResolveError {
                return
            } else {
                XCTFail("Unregistered service `\(targetType)` should throw unableToInitializeService")
            }
        }
    }
}
