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
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.clear
                viewForRoute(viewModel.rootRouter.rootRoute)
            }
            .bindToNavigation(viewModel.$navigation)
            .setupNavigation(using: viewModel.rootRouter) // must be before binding
            .animation(.smooth, value: viewModel.rootRouter.rootRoute)
            .preferredColorScheme(.dark) // Force Dark Mode for the entire app
            .task {
                viewModel.onCreated()
            }
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
