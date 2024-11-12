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
        private let dataSource: OnboardingDataSource
        private let onPurchase: () -> Void
        @ServiceLocator(.singleton) private var logger: FlickrLogger
        
        init(dataSource: OnboardingDataSource, onPurchase: @escaping () -> Void = {}) {
            self.dataSource = dataSource
            self.onPurchase = onPurchase
            self.currentPage = dataSource.pages.first!
        }
        
        private(set) lazy var termsAction: () -> Void = {
            UrlOpeningService.openUrl(withPath: "https://google.com")
        }
        
        private(set) lazy var conditionsAction: () -> Void = {
            UrlOpeningService.openUrl(withPath: "https://google.com")
        }
        
        private(set) lazy var restoreAction: () -> Void = { [weak self] in
            self?.logger.logEvent(.promo)
            self?.purchase()
        }
        
        private(set) lazy var continueAction: () -> Void = { [weak self] in
            guard let self else { return }
            switch buttonState {
            case .continue:
                openPage(currentPageNumber + 1)
            case .purchase:
                purchase()
            case .loading:
                break // ignore
            }
        }
        
        func didDragBack() {
            openPage(currentPageNumber - 1)
        }
        
        func didDragForward() {
            openPage(currentPageNumber + 1)
        }
        
        // MARK: - Private
        
        private func openPage(_ pageNumber: Int) {
            guard pageNumber < dataSource.pages.count, pageNumber >= 0 else { return }
            
            currentPageNumber = pageNumber
            currentPage = dataSource.pages[pageNumber]
            
            if pageNumber == dataSource.pages.count - 1 {
                buttonState = .purchase
            } else {
                buttonState = .continue
            }
        }
        
        private func purchase() {
            buttonState = .loading
            
            Task {
                // imitate purchase
                try await Task.sleep(for: .seconds(1))
                onPurchase()
            }
        }
    }
}
