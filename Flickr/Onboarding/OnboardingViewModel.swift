//
//  OnboardingViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import Foundation

extension OnboardingView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var buttonState: ButtonState = .continue
        @Published private(set) var currentPage: OnboardingPageType
        private var currentPageNumber: Int = 0
        private let datasource: OnboardingDatasource
        private let onPurchase: () -> Void
        
        init(datasource: OnboardingDatasource, onPurchase: @escaping () -> Void = {}) {
            self.datasource = datasource
            self.onPurchase = onPurchase
            self.currentPage = datasource.pages.first!
        }
        
        func onContinueTapped() {
            switch buttonState {
            case .continue:
                handleContinue()
            case .purchase:
                purchase()
            case .loading:
                break // ignore
            }
        }
        
        private func handleContinue() {
            currentPageNumber += 1
            currentPage = datasource.pages[currentPageNumber]
            
            if currentPageNumber == datasource.pages.count - 1 {
                buttonState = .purchase
            }
        }
        
        private func purchase() {
            buttonState = .loading
            
            Task {
                try await Task.sleep(for: .seconds(1))
                onPurchase()
            }
        }
    }
}

// MARK: - ButtonState

extension OnboardingView {
    enum ButtonState {
        case `continue`
        case purchase
        case loading
    }
}
