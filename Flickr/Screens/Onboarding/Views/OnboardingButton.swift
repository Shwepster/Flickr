//
//  OnboardingButton.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.10.2024.
//

import SwiftUI

struct OnboardingButton: View {
    let onTap: () -> Void
    let buttonState: OnboardingView.ButtonState
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Button(action: onTap) {
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
        .tint(.app.extraLightPurple)
        .scaleEffect(isAnimating ? 1.05 : 1)
        .shadow(color: .app.tint.opacity(isAnimating ? 0.3 : 0.15), radius: 16)
        .if(buttonState != .purchase) {
            // this code will remove any animation that started before
            $0.animation(nil, value: isAnimating)
        }
        .animation(
            .linear(duration: 1).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onChange(of: buttonState) { oldValue, newValue in
            isAnimating = newValue == .purchase
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

// Preview

#Preview {
    ZStack(alignment: .bottom) {
        Color.app.backgroundGradient
            .ignoresSafeArea()
        OnboardingButton(onTap: {}, buttonState: .continue)
            .padding()
    }
}
