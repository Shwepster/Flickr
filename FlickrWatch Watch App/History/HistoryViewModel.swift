//
//  HistoryViewModel.swift
//  FlickrWatch Watch App
//
//  Created by Maxim Vynnyk on 13.12.2024.
//

import Foundation
import Observation

extension HistoryView {
    @Observable
    final class ViewModel {
        private(set) var items: [HistoryItem] = []
        private let storage = HistoryStorage()
        
        init() {
            storage.clearAll()
        }
        
        func onCreated() {
            loadHistory()
        }
        
        func fillMockData() {
            storage.store([
                .init(text: "No history yet"),
                .init(text: "Search for photos"),
                .init(text: "Add photos"),
                .init(text: "Edit photos"),
                .init(text: "Delete photos")
            ])
            
            loadHistory()
        }
        
        private func loadHistory() {
            items = storage.fetch()
        }
    }
}
