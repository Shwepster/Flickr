//
//  DragController.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.10.2024.
//

import SwiftUI

extension OnboardingView {
    struct DragController {
        private(set) var isDragging = false
        private(set) var dragDirection: Edge = .trailing
        
        var animationSide: Edge {
            isDragging ? dragDirection.opposite : .trailing
        }
        
        mutating func startDrag(_ translation: CGSize) {
            isDragging = true
            dragDirection = translation.width > 0 ? .trailing : .leading
        }
        
        mutating func endDrag() {
            isDragging = false
        }
    }
}
