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
        private let onPurchase: Callback
        
        init(datasource: OnboardingDatasource, onPurchase: @escaping Callback = {}) {
            self.datasource = datasource
            self.onPurchase = onPurchase
            self.currentPage = datasource.pages.first!
        }
        
        func onContinueTapped() {
            switch buttonState {
            case .continue:
                openPage(currentPageNumber + 1)
            case .purchase:
                purchase()
            case .loading:
                break // ignore
            }
        }
        
        func didDragRight() {
            openPage(currentPageNumber - 1)
        }
        
        func didDragLeft() {
            openPage(currentPageNumber + 1)
        }
        
        // MARK: - Private
        
        private func openPage(_ pageNumber: Int) {
            guard pageNumber < datasource.pages.count, pageNumber >= 0 else { return }
            
            currentPageNumber = pageNumber
            currentPage = datasource.pages[pageNumber]
            
            if pageNumber == datasource.pages.count - 1 {
                buttonState = .purchase
            } else {
                buttonState = .continue
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
