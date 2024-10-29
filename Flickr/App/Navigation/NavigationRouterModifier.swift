//
//  NavigationRouterModifier.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 29.10.2024.
//

import SwiftUI

struct NavigationRouterModifier: ViewModifier {
    @ObservedObject var router: Router
    
    func body(content: Content) -> some View {
        NavigationStack(path: $router.routes) {
            content
                .navigationDestination(for: Route.self) { newRoute in
                    viewForRoute(newRoute)
                }
        }
        .onNavigate { action in
            withAnimation(.easeInOut) {
                applyNavigationAction(action, to: router)
            }
        }
        .fullScreenCover(item: $router.fullScreenRouter) { router in
            viewForRouter(router)
        }
        .sheet(item: $router.sheetRouter) {
            print("sheet dismissed")
        } content:{ router in
            viewForRouter(router)
        }
    }
    
    @ViewBuilder
    private func viewForRouter(_ router: Router) -> some View {
        viewForRoute(router.rootRoute)
            .presentationBackground(router.rootRoute.settings.presentationBackground)
            .presentationDetents(router.rootRoute.settings.presentationDetents)
            .setupNavigation(using: router)
    }
    
    private func applyNavigationAction(_ action: NavigationType, to router: Router) {
        switch action {
        case .push(to: let route):
            router.addRoute(route)
        case .pushOnTop(let route):
            router.getTopRouter().addRoute(route)
        case .unwind(to: let route):
            router.removeRoutes(upTo: route)
        case .present(let route):
            router.presentRoute(route)
        case .back:
            router.removeRoute()
        case .dismiss:
            router.dismiss()
        }
    }
}

extension View {
    func setupNavigation(using router: Router) -> some View {
        modifier(NavigationRouterModifier(router: router))
    }
}

@MainActor @ViewBuilder
func viewForRoute(_ route: Route) -> some View {
    switch route.screen {
    case let .onboarding(dataSource, onPurchase):
        let viewModel = OnboardingView.ViewModel(dataSource: dataSource, onPurchase: onPurchase)
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
