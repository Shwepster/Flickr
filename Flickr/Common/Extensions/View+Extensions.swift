//
//  View+Extensions.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 11.10.2024.
//

import SwiftUI
import UIKit

extension View {
    func asUIImage() -> UIImage? {
        ImageRenderer(content: self).uiImage
    }
    
    @ViewBuilder
    func isHidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }

    @ViewBuilder
    func ifLet<T, Transform: View> (_ value: T?, transform: (Self, T) -> Transform) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Transform: View> (_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func foreground<Overlay: View>(_ overlay: Overlay) -> some View {
        self.overlay(overlay).mask(self)
    }
}
