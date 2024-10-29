//
//  NavigationRouteBind.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.10.2024.
//

import SwiftUI
import Combine

struct NavigationRouteBind<T: Publisher<NavigationType?, Never>>: ViewModifier {
    @Environment(\.navigate) private var navigate
    var navigationRoute: T
    
    func body(content: Content) -> some View {
        content.onReceive(navigationRoute) { output in
            if let output {
                navigate(output)
            }
        }
    }
}

extension View {
    func bindToNavigation<T: Publisher<NavigationType?, Never>>(_ navigationRoute: T) -> some View {
        modifier(NavigationRouteBind(navigationRoute: navigationRoute))
    }
}
