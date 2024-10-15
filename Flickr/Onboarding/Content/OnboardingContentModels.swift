//
//  OnboardingContentModels.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import Foundation

struct WelcomePageModel: Equatable {
    let title: String
    let description: String
}

struct FeaturesPageModel: Equatable {
    let title: String
    let features: [String]
}

struct PurchasePageModel: Equatable {
    let title: String
    let features: [String]
    let price: Decimal
}
