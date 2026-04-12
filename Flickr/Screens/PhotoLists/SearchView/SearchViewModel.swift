//
//  SearchViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

import Foundation
import Combine

extension SearchableMainListView {
    @MainActor
    final class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var history: [HistoryItem] = []
        @ServiceLocator private var storage: HistoryStorage
        @ServiceLocator(.singleton) private var logger: FlickrLogger
        @ServiceLocator(.singleton) private var watchConnection: WatchConnectionService
        let listViewModel = MainListView.ViewModel()
        private var cancellables: Set<AnyCancellable> = []
        
        func onCreate() {
            listenInfoFromWatch()
        }
        
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
        
        private func listenInfoFromWatch() {
            watchConnection.userInfoPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] userInfo in
                    guard let self, let historyData = userInfo[WatchTransferKeys.history.rawValue] as? Data else {
                        print("error: invalid history data: \(userInfo)")
                        return
                    }
                    
                    do {
                        let history = try JSONDecoder().decode([HistoryItem].self, from: historyData)
                        storage.store(history, syncWithCompanionApp: false)
                        syncHistory()
                    } catch {
                        print("failed decoding history: \(error)")
                    }
                }.store(in: &cancellables)
        }
    }
}
