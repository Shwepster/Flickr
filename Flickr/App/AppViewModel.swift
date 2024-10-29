//
//  AppViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI
import Combine

extension FlickrApp {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var navigation: NavigationType?
        @Published private(set) var rootRouter = Router(parentRouter: nil, rootRoute: .init(screen: .main))
        @ServiceLocator(.singleton) private var campaignMediator: CampaignViewMediator
        private var cancellables: Set<AnyCancellable> = []
        
        init(showOnboarding: Bool = true) {            
            if showOnboarding {
                let screen: Route.Screen = .onboarding(OnboardingView.OnboardingDatasourceNew()) { [weak self] in
                    self?.rootRouter.rootRoute = .init(screen: .main)
                }
                
                rootRouter.rootRoute = .init(screen: screen)
            }
            
            rootRouter.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
            
            clearCache()
        }
        
        func onCreated() {
            campaignMediator.navigation
                .sink { [weak self] navigation in
                    self?.navigation = navigation
                }
                .store(in: &cancellables)
        }
        
        // MARK: - Private
        
        private func clearCache() {
            @ServiceLocator var cacheService: ImageCacheService
            Task(priority: .high) {
                await cacheService.clearCache()
            }
        }
    }
}
