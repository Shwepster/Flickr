//
//  OnboardingDatasourceDefault.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    struct OnboardingDatasourceDefault: OnboardingDatasource {
        let pages: [OnboardingPageType]
        
        init() {
            self.pages = [
                .welcome(.init(title: "Lets Get Started", description: "Welcome to Flickr!")),
                .features(
                    .init(
                        title: "Features",
                        features: ["SwiftUI", "Combine", "EnvironmentObject", "StateObject", "ObservableObject"]
                    )
                ),
                .features(
                    .init(
                        title: "Features",
                        features: ["Free", "Pro", "Enterprise"]
                    )
                ),
                .purchase(.init(title: "Complete Your Purchase", features: [], price: 99.99))
            ]
        }
    }
}
