//
//  FlickrApp.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import SwiftUI

@main
struct FlickrApp: App {
    @StateObject private var viewModel = ViewModel()
    
    init() {
        AppServicesRegistrator.registerAllServices()
        clearCache()
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let viewModel = viewModel.onboardingVM {
                    OnboardingView(viewModel: viewModel)
                } else {
                    NavigationView {
                        SearchableMainListView()
                    }
                }
            }
            .animation(.smooth, value: viewModel.onboardingVM == nil)
            .preferredColorScheme(.dark) // Force Dark Mode for the entire app
        }
    }
    
    private func clearCache() {
        @ServiceLocator var cacheService: ImageCacheService
        Task(priority: .high) {
            await cacheService.clearCache()
        }
    }
    
    private func configureNavigationBarAppearance() {
        let largeBarAppearance = UINavigationBarAppearance()
        largeBarAppearance.configureWithOpaqueBackground()
        largeBarAppearance.backgroundColor = UIColor(.app.barBackground)
        largeBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        largeBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().scrollEdgeAppearance = largeBarAppearance
        
        let smallBarAppearance = UINavigationBarAppearance()
        smallBarAppearance.configureWithDefaultBackground()
        smallBarAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        smallBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        smallBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = smallBarAppearance
    }
}
