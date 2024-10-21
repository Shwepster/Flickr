//
//  SearchViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

import Foundation

extension SearchableMainListView {
    @MainActor
    final class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var history: [HistoryItem] = []
        @ServiceLocator private var storage: HistoryStorage
        @ServiceLocator(.singleton) private var logger: FlickrLogger
        let listViewModel = MainListView.ViewModel()
        
        func onAppear() {
            syncHistory()
        }
        
        func deleteItem(_ item: HistoryItem) {
            storage.deleteItem(item)
            syncHistory()
        }
        
        func clearHistory() {
            storage.clearAll()
            syncHistory()
        }
        
        func search() {
            Task {
                logger.logEvent(.search)
                await listViewModel.onSearch(searchText)
                
                guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty else { return }
                let item = HistoryItem(text: searchText)
                storage.store(item)
                syncHistory()
            }
        }
        
        // MARK: - Helpers
        
        private func syncHistory() {
            history = storage.fetch()
        }
    }
}
