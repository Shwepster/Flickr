//
//  OnboardingDatasourceDefault.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    struct OnboardingDatasourceDefault: OnboardingDataSource {
        let pages: [OnboardingPageType]
        
        init() {
            self.pages = [
                .welcome(.init(title: "Lets Get Started", description: "Welcome to Flickr!")),
                .features(
                    .init(
                        title: "Features",
                        features: [
                            "SwiftUI",
                            "Combine",
                            "EnvironmentObject",
                            "StateObject",
                            "ObservableObject"
                        ],
                        images: [],
                        bottomText: []
                    )
                ),
                .features(
                    .init(
                        title: "Features",
                        features: ["Free", "Pro", "Enterprise"],
                        images: [.init(.placeholder), .init(.placeholder), .init(.placeholder)],
                        bottomText: ["New Features", "Upgrade Now"]
                    )
                ),
                .purchase(
                    .init(
                        type: .default,
                        title: "Complete Your Purchase",
                        features: [],
                        images: [],
                        price: 99.99
                    )
                )
            ]
        }
    }
}
