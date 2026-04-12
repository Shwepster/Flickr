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

//MARK: - Hashable

extension OnboardingView.OnboardingPageType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .welcome(let model):
            hasher.combine(model.title)
            hasher.combine(model.description)
        case .features(let model):
            hasher.combine(model.features)
            hasher.combine(model.title)
            hasher.combine(model.bottomText)
        case .purchase(let model):
            hasher.combine(model.title)
            hasher.combine(model.price)
        case .image(let model):
            hasher.combine(model.text)
            hasher.combine(model.title)
        }
    }
}
