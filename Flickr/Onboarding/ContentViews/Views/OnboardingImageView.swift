//
//  OnboardingImageView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 17.10.2024.
//

import SwiftUI

struct OnboardingImageView: View {
    let image: Image
    let text: String
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.3)
            
            Text(text)
                .font(.title)
                .foregroundColor(.white)
                .shadow(radius: 10)
        }
    }
}

#Preview {
    OnboardingImageView(image: .init(.placeholder), text: "Test")
}
