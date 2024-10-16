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
        private var didDragLeft: Bool?
        
        var draggedFromSide: Edge { didDragLeft == false ? .leading : .trailing }
        var isLeft: Bool { didDragLeft == true }
        var isRight: Bool { didDragLeft == false }
        
        mutating func startDrag(_ translation: CGSize) {
            isDragging = true
            if translation.width > 15 {
                didDragLeft = false
            } else if translation.width < -15 {
                didDragLeft = true
            } else {
                didDragLeft = nil
            }
        }
        
        mutating func endDrag() {
            isDragging = false
            didDragLeft = nil
        }
    }
}
