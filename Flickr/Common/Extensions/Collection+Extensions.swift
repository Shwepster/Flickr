//
//  Collection+Extensions.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

extension Collection {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var results = [T]()
        results.reserveCapacity(count)
        
        for element in self {
            let transformed = try await transform(element)
            results.append(transformed)
        }
        
        return results
    }
}
