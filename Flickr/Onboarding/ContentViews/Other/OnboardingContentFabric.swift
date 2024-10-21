//
//  OnboardingContentFabric.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

extension OnboardingView {
    @MainActor
    enum OnboardingContentFabric {
        @ViewBuilder
        static func makeTitle(for type: OnboardingPageType) -> some View {
            let title = switch type {
            case .welcome(let model):
                model.title
            case .features(let model):
                model.title
            case .purchase(let model):
                model.title
            case .image(let model):
                model.title
            }
            
            Text(title)
                .font(.title)
                .bold()
        }
        
        @ViewBuilder
        static func makeContent(for type: OnboardingPageType) -> some View {
            switch type {
            case .welcome(let model):
                WelcomeOnboardingView(welcomeText: model.description)
            case .features(let model):
                FeaturesOnboardingView(features: model.features, images: model.images)
            case .purchase(let model):
                PurchaseOnboardingView(
                    price: model.price,
                    features: model.features,
                    images: model.images
                )
            case .image(let model):
                OnboardingImageView(image: model.image, text: model.text)
            }
        }
        
        @ViewBuilder
        static func makeBottomContent(
            for type: OnboardingPageType,
            termsAction: @escaping () -> Void,
            conditionsAction: @escaping () -> Void,
            restoreAction: @escaping () -> Void
        ) -> some View {
            switch type {
            case .welcome, .image:
                Color.clear
            case .features(let model):
                OnboardingBottomView(texts: model.bottomText)
            case .purchase:
                PurchaseOnboardingBottomView(
                    termsAction: termsAction,
                    conditionsAction: conditionsAction,
                    restoreAction: restoreAction
                )
            }
        }
    }
}
