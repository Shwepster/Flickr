//
//  OnboardingContentModels.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct WelcomePageModel: Equatable {
    let title: String
    let description: String
}

struct FeaturesPageModel: Equatable {
    let title: String
    let features: [String]
    let images: [Image]
    let bottomText: [String]
}

struct PurchasePageModel: Equatable {
    let type: PageType
    let title: String
    let features: [String]
    let images: [Image]
    let price: Decimal
    
    enum PageType {
        case `default`
        case new
    }
}

struct ImagePageModel: Equatable {
    let title: String
    let image: Image
    let text: String
}
