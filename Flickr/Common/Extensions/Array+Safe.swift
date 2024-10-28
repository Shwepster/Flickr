//
//  Array+Safe.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 23.10.2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
