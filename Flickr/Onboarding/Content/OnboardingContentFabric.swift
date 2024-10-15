//
//  OnboardingContentFabric.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

extension OnboardingView {
    enum OnboardingContentFabric {
        @ViewBuilder
        static func makeView(for type: OnboardingPageType) -> some View {
            switch type {
            case .welcome(let model):
                WelcomeOnboardingView(welcomeText: model.description)
            case .features(let model):
                FeaturesOnboardingView(features: model.features)
            case .purchase(let model):
                PurchaseOnboardingView(price: model.price, features: model.features)
            }
        }
    }
}
