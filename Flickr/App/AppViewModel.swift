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
        @ServiceLocator(.singleton) private var purchaseService: PurchaseService
        @ServiceLocator(.singleton) private var watchConnection: WatchConnectionService
        private var cancellables: Set<AnyCancellable> = []
        
        init(showOnboarding: Bool = true) {            
            if showOnboarding {
                let screen: Route.Screen = .onboarding(OnboardingView.OnboardingDatasourceNew())
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
            
            purchaseService.isPurchased
                .sink { [weak self] isPurchased in
                    if isPurchased {
                        self?.rootRouter.replaceRoot(with: .init(screen: .main))
                    }
                }
                .store(in: &cancellables)
            
            watchConnection.activateSession()
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
