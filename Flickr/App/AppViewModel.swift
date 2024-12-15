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
        private lazy var campaignMediator: CampaignViewMediator = ServiceContainer.forceResole()
        private lazy var purchaseService: PurchaseService = ServiceContainer.forceResole()
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
            
        }
        
        func onCreated() {
            clearCache()

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
        }
        
        // MARK: - Private
        
        private func clearCache() {
            Task(priority: .low) {
                @ServiceLocator var cacheService: ImageCacheService
                await cacheService.clearCache()
            }
        }
    }
}
