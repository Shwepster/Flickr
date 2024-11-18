//
//  Screen+View.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.11.2024.
//

import SwiftUI

extension Route.Screen: View {
    var body: some View {
        switch self {
        case let .onboarding(dataSource):
            let viewModel = OnboardingView.ViewModel(dataSource: dataSource)
            OnboardingView(viewModel: viewModel)
        case .main:
            SearchableMainListView()
        case .pageView:
            PageViewScreen()
        case .editPhoto(let photo):
            let viewModel = EditorView.ViewModel(photo: photo)
            EditorView(viewModel: viewModel)
        case .campaign(let view):
            AnyView(view)
        }
    }
}
