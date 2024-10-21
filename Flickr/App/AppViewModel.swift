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
        @Published var isCampaignPresented: Bool = false
        @Published private(set) var onboardingVM: OnboardingView.ViewModel?
        @ServiceLocator(.singleton) private var campaignMediator: CampaignViewMediator
        private var cancellables: Set<AnyCancellable> = []
        
        init() {
            onboardingVM = .init(
                datasource: [
                    OnboardingView.OnboardingDatasourceNew(),
                    OnboardingView.OnboardingDatasourceDefault()
                ].randomElement()!,
                onPurchase: { [unowned self] in
                self.onboardingVM = nil
            })
        }
        
        func onCreated() {
            campaignMediator.campaignSubject.sink { [weak self] campaign in
                self?.isCampaignPresented = true
            }.store(in: &cancellables)
        }
        
        func onCampaignDismiss() {
            campaignMediator.campaignDidEnd()
        }
        
        @ViewBuilder
        func getCampaignView() -> some View {
            if let view = campaignMediator.getView() {
                AnyView(view)
            } else {
                EmptyView()
            }
        }
    }
}
