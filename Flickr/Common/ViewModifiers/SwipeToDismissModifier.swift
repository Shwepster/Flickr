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
                                dismiss()
                            }
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > dismissDistance {
                            dismiss()
                        }
                        offset = .zero
                        isScrollDisabled = false
                    }
            )
            .animation(.bouncy, value: offset)
    }
}

extension View {
    func swipeToDismiss() -> some View {
        modifier(SwipeToDismissModifier())
    }
}
