//
//  OnboardingDatasource.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    protocol OnboardingDatasource {
        var pages: [OnboardingPageType] { get }
    }
}

extension OnboardingView.OnboardingDatasource {
    static var `default`: Self { OnboardingView.OnboardingDatasourceDefault() as! Self }
    static var new: Self { OnboardingView.OnboardingDatasourceNew() as! Self }
}
