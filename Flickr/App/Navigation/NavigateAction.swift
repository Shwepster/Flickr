//
//  NavigateAction.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 29.10.2024.
//

import SwiftUI

@MainActor
struct NavigateAction: Sendable {
    typealias Action = @Sendable @MainActor (NavigationType) -> ()
    let action: Action
    
    func callAsFunction(_ navigationType: NavigationType) {
        action(navigationType)
    }
}

enum NavigationType {
    case push(Route) // pushes on current router
    case pushOnTop(Route) // pushed on top router
    case unwind(to: Route)
    case present(Route)
    case back
    case dismiss
}

extension EnvironmentValues {
    var navigate: NavigateAction {
        set { self[NavigateEnvironmentKey.self] = newValue }
        get { self[NavigateEnvironmentKey.self] }
    }
}

struct NavigateEnvironmentKey: EnvironmentKey {
    static let defaultValue: NavigateAction = .init(action: { _ in
        print("default navigate action")
    })
}

extension View {
    func onNavigate(_ action: @escaping NavigateAction.Action) -> some View {
        environment(\.navigate, NavigateAction(action: action))
    }
}
