//
//  FeaturesOnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct FeaturesOnboardingView: View {
    let features: [String]
    let images: [Image]
    
    var body: some View {
        VStack {
            featureList
            imageList
            Spacer()
        }
    }
    
    @ViewBuilder
    private var featureList: some View {
        VStack {
            ForEach(features) { feature in
                Text(feature)
            }
            .foregroundStyle(.secondary)
            .font(.headline)
            .italic()
            .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 50, alignment: .leading)
        }
        .padding()
        .background(.app.barBackground.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .isRemoved(features.isEmpty)
    }
    
    @ViewBuilder
    private var imageList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(images.indices, id: \.self) { i in
                    images[i]
                        .resizable()
                        .scaledToFill()
                        .frame(width: 125, height: 125)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .isRemoved(images.isEmpty)
    }
}

#Preview {
    FeaturesOnboardingView(
        features: ["SwiftUI", "Combine", "UIKit"],
        images: [.init(.placeholder)]
    )
}
