//
//  OnboardingPageType.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    enum OnboardingPageType: Equatable {
        case welcome(WelcomePageModel)
        case features(FeaturesPageModel)
        case purchase(PurchasePageModel)
        case image(ImagePageModel)
        
        var title: String {
            switch self {
            case .welcome(let model): return model.title
            case .features(let model): return model.title
            case .purchase(let model): return model.title
            case .image(let model): return model.title
            }
        }
    }
}
