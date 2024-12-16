//
//  FlickrWatchApp.swift
//  FlickrWatch Watch App
//
//  Created by Maxim Vynnyk on 13.12.2024.
//

import SwiftUI

@main
struct FlickrWatch_Watch_AppApp: App {
    private let stateObserver = AppStateObserver()
    
    var body: some Scene {
        WindowGroup {
            HistoryView()
                .task {
                    FlickrWatchAppServices.watchConnectionService.activateSession()
                }
        }
    }
}

enum FlickrWatchAppServices {
    static let watchConnectionService = WatchConnectionService()
}

final class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    
}
