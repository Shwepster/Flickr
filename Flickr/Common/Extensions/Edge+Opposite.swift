//
//  File.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 17.10.2024.
//
import SwiftUI

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}
