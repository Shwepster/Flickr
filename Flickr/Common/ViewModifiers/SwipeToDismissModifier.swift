//
//  SwipeToDismissModifier.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

import SwiftUI

struct SwipeToDismissModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @State private var offset = CGSize.zero
    @State private var isScrollDisabled = false
    let onDismiss: () -> Void
    private let dismissDistance: CGFloat = 150
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset.height)
            .disabled(isScrollDisabled) // Disable other gestures when swiping
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            offset = gesture.translation
                            isScrollDisabled = true
                            
                            if gesture.translation.height > dismissDistance*3 {
                                // if swiped far enough - dismiss without gesture ending
                                dismissView()
                            }
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > dismissDistance {
                            dismissView()
                        }
                        offset = .zero
                        isScrollDisabled = false
                    }
            )
            .animation(.bouncy, value: offset)
    }
    
    private func dismissView() {
        dismiss()
        onDismiss()
    }
}

extension View {
    func swipeToDismiss(onDismiss: @escaping (() -> Void) = {}) -> some View {
        modifier(SwipeToDismissModifier(onDismiss: onDismiss))
    }
}
