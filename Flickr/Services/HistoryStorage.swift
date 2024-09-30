//
//  HistoryStorage.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

import Foundation

struct HistoryStorage {
    private static let key = "history"
    private static let limit: Int = 5
    private let decoder: JSONDecoder = .init()
    private let encoder: JSONEncoder = .init()
    
    func store(_ history: [HistoryItem]) {
        let limitedHistory = Array(history.prefix(Self.limit))
        
        do {
            let data = try encoder.encode(limitedHistory)
            UserDefaults.standard.set(data, forKey: Self.key)
        } catch {
            print("Error encoding history: \(error)")
        }
    }
    
    func store(_ item: HistoryItem) {
        var history = fetch()
        history.insert(item, at: 0)
        store(history)
    }
    
    func deleteItem(_ item: HistoryItem) {
        var history = fetch()
        history.removeAll(where: { $0.id == item.id })
        store(history)
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: Self.key)
    }
    
    func fetch() -> [HistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: Self.key) else { return [] }
        
        do {
            let history = try decoder.decode([HistoryItem].self, from: data)
            return history
        } catch {
            print("Error decoding history: \(error)")
            return []
        }
    }
}
