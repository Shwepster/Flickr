//
//  OnboardingDataSource.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

extension OnboardingView {
    protocol OnboardingDataSource {
        var pages: [OnboardingPageType] { get }
    }
}

extension OnboardingView.OnboardingDataSource {
    static var `default`: Self { OnboardingView.OnboardingDatasourceDefault() as! Self }
    static var new: Self { OnboardingView.OnboardingDatasourceNew() as! Self }
}
