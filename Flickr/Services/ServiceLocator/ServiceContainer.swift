//
//  ServiceContainer.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 25.09.2024.
//

import Foundation
import Synchronization

enum ServiceContainer {
    private static let factories: Mutex<[String: @Sendable () -> Sendable]> = .init([:])
    private static let cache: Mutex<[String: Sendable]> = .init([:])
    
    // MARK: - Register
    
    static func register<ServiceT: Sendable>(_ type: ServiceT.Type,
                                             factory: @autoclosure @escaping @Sendable () -> ServiceT) {
        let key = String(describing: type)
        factories.withLock { $0[key] = factory }
        cache.withLock { $0[key] = nil } // remove old singletone
    }
    
    static func register<ServiceT: Sendable>(_ type: ServiceT.Type,
                                             factory: @escaping @Sendable () -> ServiceT) {
        register(type, factory: factory())
    }
    
    // MARK: Resolve
    
    static func resolve<ServiceT: Sendable>(_ type: ServiceT.Type,
                                            lifetime: ServiceType) throws(ResolveError) -> ServiceT {
        let key = String(describing: type)
        
        switch lifetime {
        case .singleton:
            // get existing
            if let service = cache.withLock({ $0[key] }) as? ServiceT {
                return service
            }
            
            // factories.withLock { $0[key]?() } will cause deadlock
            // because closure, executed inside lock, can also try to use lock which causes deadlock
            
            // Get the factory outside the lock to avoid deadlock
            let factory = factories.withLock { $0[key] }
            
            // create new
            if let service = factory?() as? ServiceT {
                cache.withLock { $0[key] = service }
                return service
            }
        case .new:
            // Get the factory outside the lock to avoid deadlock
            let factory = factories.withLock { $0[key] }
            
            if let service = factory?() as? ServiceT {
                return service
            }
        }
        throw .unableToInitializeService(key)
    }
    
    static func resolve<ServiceT: Sendable>(lifetime: ServiceType) throws(ResolveError) -> ServiceT {
        try resolve(ServiceT.self, lifetime: lifetime)
    }
    
    static func unregisterAll() {
        factories.withLock { $0.removeAll() }
        cache.withLock { $0.removeAll() }
    }
}

// MARK: - ServiceType

extension ServiceContainer {
    enum ServiceType {
        case singleton
        case new
    }
}

// MARK: - ResolveError

extension ServiceContainer {
    enum ResolveError: Error, Equatable {
        case unableToInitializeService(String)
    }
}
