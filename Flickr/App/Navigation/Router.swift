//
//  Router.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 29.10.2024.
//

import SwiftUI

final class Router: ObservableObject, Identifiable {
    let id: UUID = .init()
    @Published var rootRoute: Route
    @Published var routes: [Route] = []
    
    // need two routers, to use .sheet or .fullScreen presentation without animation problems
    @Published var sheetRouter: Router?
    @Published var fullScreenRouter: Router?
    private weak var parentRouter: Router?
    
    init(parentRouter: Router?, rootRoute: Route, routes: [Route] = []) {
        self.routes = routes
        self.rootRoute = rootRoute
        self.parentRouter = parentRouter
    }
    
    deinit {
        print("router deinit: \(rootRoute.id)")
        rootRoute.onDismiss?()
    }
    
    // MARK: - Actions
    func addRoute(_ route: Route) {
        routes.append(route)
    }
    
    func presentRoute(_ route: Route) {
        let router = getTopRouter()
        
        if route.settings.isFullScreen {
            router.sheetRouter = nil
            router.fullScreenRouter = Router(parentRouter: self, rootRoute: route)
        } else {
            router.fullScreenRouter = nil
            router.sheetRouter = Router(parentRouter: self, rootRoute: route)
        }
    }
    
    func removeRoutes(upTo route: Route) {
        if let index = routes.lastIndex(of: route) {
            routes = Array(routes.prefix(upTo: index + 1))
        } else if route == rootRoute {
            routes.removeAll()
        }
    }
    
    func removeRoute() {
        guard routes.isNotEmpty else { return }
        routes.removeLast()
    }
    
    func dismiss() {
        parentRouter?.fullScreenRouter = nil
        parentRouter?.sheetRouter = nil
    }
    
    func getTopRouter() -> Router {
        let top = fullScreenRouter ?? sheetRouter
        if let top {
            return top.getTopRouter()
        }
        
        return self
    }
}
