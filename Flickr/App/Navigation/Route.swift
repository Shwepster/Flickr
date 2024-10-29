//
//  Route.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 29.10.2024.
//

import SwiftUI

struct Route {
    let screen: Screen
    let settings: PresentationSettings
    let onDismiss: (() -> Void)?
    
    init(screen: Screen, settings: PresentationSettings = .init(), onDismiss: (() -> Void)? = nil) {
        self.screen = screen
        self.settings = settings
        self.onDismiss = onDismiss
    }
    
    enum Screen {
        case onboarding(OnboardingView.OnboardingDataSource, () -> Void)
        case main
        case editPhoto(PhotoModel)
        case pageView
        case campaign(any View)
    }
}

// MARK: - PresentationSettings
extension Route {
    struct PresentationSettings {
        let isFullScreen: Bool
        let presentationDetents: Set<PresentationDetent>
        let presentationBackground: Material
        
        init(
            isFullScreen: Bool = false,
            presentationDetents: Set<PresentationDetent> = [],
            presentationBackground: Material = .regularMaterial
        ) {
            self.isFullScreen = isFullScreen
            self.presentationDetents = presentationDetents
            self.presentationBackground = presentationBackground
        }
    }
}

// MARK: - Identifiable
extension Route: Identifiable {
    var id: Int {
        switch screen {
        case .onboarding: 1
        case .main: 2
        case .editPhoto: 3
        case .pageView: 4
        case .campaign: 5
        }
    }
}

// MARK: - Hashable
extension Route: Hashable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
