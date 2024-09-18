//
//  FlickrApp.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import SwiftUI

@main
struct FlickrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                if let apiKey = ProcessInfo.processInfo.environment["KEY"] {
                    print("Flickr API Key: \(apiKey)")
                } else {
                    print("API key not found. Set it in environment variable KEY")
                }
            }
        }
    }
}
