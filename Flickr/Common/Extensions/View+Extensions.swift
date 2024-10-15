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
    
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
