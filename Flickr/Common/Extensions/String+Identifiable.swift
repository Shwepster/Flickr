//
//  String+Identifiable.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 11.10.2024.
//

import Foundation

extension String: @retroactive Identifiable {
    public var id: String { self }
}
