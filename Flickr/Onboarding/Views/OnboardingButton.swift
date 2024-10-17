//
//  OnboardingButton.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.10.2024.
//

import SwiftUI
import CoreGraphics

struct OnboardingButton: View {
    let onTap: () -> Void
    let buttonState: OnboardingView.ButtonState
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Button {
            withAnimation {
                onTap()
            }
        } label: {
            HStack(spacing: 0) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.secondary)
                    .scaleEffect(0.8)
                    .padding(.trailing, -16)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    .isHidden(buttonState != .loading)
                
                Text(title)
                    .frame(maxWidth: .infinity)
                
                Color.clear
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 0)
                    .hidden()
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(.app.lightPurple)
        .scaleEffect(isAnimating ? 1.05 : 1)
        .shadow(color: .app.extraLightPurple.opacity(isAnimating ? 0.3 : 0.15), radius: 16)
        .animation(
            .linear(duration: 1).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
    
    private var title: String {
        switch buttonState {
        case .continue:
            "Continue"
        case .purchase:
            "Purchase"
        case .loading:
            "Loading"
        }
    }
}
