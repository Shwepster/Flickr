//
//  ServiceLocator.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 25.09.2024.
//

import Foundation

@propertyWrapper
struct ServiceLocator<ServiceT: Sendable> {
    private var service: ServiceT
    
    init(_ lifetime: ServiceContainer.ServiceType = .new) {
        do {
            service = try ServiceContainer.resolve(ServiceT.self, lifetime: lifetime)
        } catch {
            fatalError("Error: \(error) for type: \(String(describing: ServiceT.self))")
        }
    }
    
    var wrappedValue: ServiceT {
        get { service }
        set { service = newValue }
    }
}
