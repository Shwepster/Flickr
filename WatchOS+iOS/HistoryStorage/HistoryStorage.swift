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
    
    func store(_ history: [HistoryItem], syncWithCompanionApp: Bool = true) {
        let limitedHistory = Array(history.prefix(Self.limit))
        
        do {
            let data = try encoder.encode(limitedHistory)
            UserDefaults.standard.set(data, forKey: Self.key)
            if syncWithCompanionApp {
                sendToCompanionApp(limitedHistory)
            }
        } catch {
            print("Error encoding history: \(error)")
        }
    }
    
    private func sendToCompanionApp(_ history: [HistoryItem]) {
#if os(iOS)
        @ServiceLocator(.singleton) var watchService: WatchConnectionService
        watchService.sendHistory(history)
#endif
        
#if os(watchOS)
        FlickrWatchAppServices.watchConnectionService.sendHistory(history)
#endif
    }
    
    func store(_ item: HistoryItem) {
        var history = fetch()
        
        if let index = history.firstIndex(of: item) {
            // if item is in history, move it to top
            history.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
        } else {
            history.insert(item, at: 0)
        }

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
