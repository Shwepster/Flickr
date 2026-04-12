//
//  String+Error.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 11.10.2024.
//

import Foundation

extension String: @retroactive Error {}
extension String: @retroactive LocalizedError {
    public var errorDescription: String? { self }
}
