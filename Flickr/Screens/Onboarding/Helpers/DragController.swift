//
//  DragController.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.10.2024.
//

import SwiftUI

extension OnboardingView {
    struct DragController {
        let onDrag: (Edge) -> Void
        var translation: CGFloat = .zero
        private(set) var dragDirection: Edge = .leading
        private let dragThreshold: CGFloat = 100
        private var isDragPossible = true
        
        init(onDrag: @escaping (Edge) -> Void) {
            self.onDrag = onDrag
        }
        
        mutating func onDragChange(_ translation: CGSize) {
            guard isDragPossible else { return }
            dragDirection = translation.width > 0 ? .trailing : .leading
            self.translation = translation.width
            
            if abs(translation.width) > dragThreshold {
                onDrag(dragDirection)
                finishDrag()
            }
        }
        
        mutating func onDragEnd() {
            translation = .zero
            dragDirection = .leading
            isDragPossible = true
        }
        
        mutating private func finishDrag() {
            isDragPossible = false
            translation = .zero
        }
    }
}
