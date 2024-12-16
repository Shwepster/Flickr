//
//  HistoryItem.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

struct HistoryItem: Identifiable, Equatable, Codable {
    var id: String { text }
    let text: String
}
