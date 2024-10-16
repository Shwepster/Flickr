//
//  OnboardingButton.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.10.2024.
//

import SwiftUI

struct OnboardingButton: View {
    let onTap: Callback
    let buttonState: OnboardingView.ButtonState
    
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
        .shadow(color: .app.extraLightPurple.opacity(0.1), radius: 16)
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
