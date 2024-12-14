//
//  HistoryViewModel.swift
//  FlickrWatch Watch App
//
//  Created by Maxim Vynnyk on 13.12.2024.
//

import Foundation
import Observation
import WatchConnectivity
import Combine

extension HistoryView {
    @Observable
    final class ViewModel: NSObject {
        private(set) var items: [HistoryItem] = []
        private let storage = HistoryStorage()
        private(set) var transfers = WCSession.default.outstandingUserInfoTransfers
        private let watchService = FlickrWatchAppServices.watchConnectionService
        private var cancellables: Set<AnyCancellable> = []
        
        func onCreated() {
            loadHistory()
            listenUserInfoFromIOS()
        }
        
        func deleteItem(_ item: HistoryItem) {
            storage.deleteItem(item)
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
        
        private func listenUserInfoFromIOS() {            
            watchService.userInfoPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] userInfo in
                    guard let self, let historyData = userInfo[WatchTransferKeys.history.rawValue] as? Data else {
                        print("error: invalid history data: \(userInfo)")
                        return
                    }
                    
                    do {
                        let history = try JSONDecoder().decode([HistoryItem].self, from: historyData)
                        storage.store(history, syncWithCompanionApp: false)
                        loadHistory()
                    } catch {
                        print("failed decoding history: \(error)")
                    }
                }.store(in: &cancellables)
        }
    }
}
