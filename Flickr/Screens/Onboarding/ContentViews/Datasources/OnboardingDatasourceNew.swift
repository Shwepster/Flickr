//
//  OnboardingDatasourceNew.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    struct OnboardingDatasourceNew: OnboardingDataSource {
        let pages: [OnboardingPageType]
        
        init() {
            self.pages = [
                .welcome(.init(title: "", description: "Welcome to Flickr")),
                .image(
                    .init(
                        title: "Best of Flickr",
                        image: .init(.placeholder),
                        text: "Lorem ipsum dolor sit amet"
                    )
                ),
                .purchase(
                    .init(
                        type: .new,
                        title: "Complete Your Purchase\nAnd Get:",
                        features: ["Music", "Videos", "Photos", "Groups", "Pages"] ,
                        images: [],
                        price: 29.99
                    )
                )
            ]
        }
    }
}
