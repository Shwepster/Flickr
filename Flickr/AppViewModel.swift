//
//  AppViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import Foundation

extension FlickrApp {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var onboardingVM: OnboardingView.ViewModel?
        
        init() {
            onboardingVM = .init(
                datasource: OnboardingView.OnboardingDatasourceNew(),
                onPurchase: { [unowned self] in
                self.onboardingVM = nil
            })
        }
    }
}
