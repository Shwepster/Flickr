//
//  FlickrApp.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import SwiftUI

@main
struct FlickrApp: App {
    @StateObject private var viewModel = ViewModel(showOnboarding: false)
    
    init() {
        AppServicesRegistrator.registerAllServices()
        configureNavigationBarAppearance()
        clearCache()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.clear
                getContentView()
            }
            .animation(.smooth, value: viewModel.onboardingVM == nil)
            .preferredColorScheme(.dark) // Force Dark Mode for the entire app
            .sheet(isPresented: $viewModel.isCampaignPresented) {
                viewModel.onCampaignDismiss()
            } content: {
                viewModel.getCampaignView()
            }
            .task {
                viewModel.onCreated()
            }
        }
    }
    
    @ViewBuilder
    private func getContentView() -> some View {
        if let viewModel = viewModel.onboardingVM {
            OnboardingView(viewModel: viewModel)
        } else {
            SearchableMainListView()
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
