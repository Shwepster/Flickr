//
//  OnboardingDatasourceNew.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    struct OnboardingDatasourceNew: OnboardingDatasource {
        let pages: [OnboardingPageType]
        
        init() {
            self.pages = [
                .welcome(.init(title: "", description: "Welcome to Flickr")),
                .purchase(
                    .init(
                        title: "Complete Your Purchase\nAnd Get:",
                        features: ["Music", "Videos", "Photos", "Groups", "Pages"] ,
                        price: 29.99
                    )
                )
            ]
        }
    }
}
