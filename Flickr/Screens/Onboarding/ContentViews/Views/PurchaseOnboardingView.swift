//
//  PurchaseOnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct PurchaseOnboardingView: View {
    let price: Decimal
    let features: [String]
    let images: [Image]
    
    var body: some View {
        if features.isNotEmpty {
            FeaturesOnboardingView(features: features, images: images)
        } else {
            Spacer()
        }
        
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.app.extraLightPurple)
            
            Text("Purchase for only \(price.formatted(.currency(code: "USD")))")
                .font(.title2)
                .italic()
        }
        .padding()
    }
}

#Preview {
    PurchaseOnboardingView(
        price: 99.99,
        features: [
            "Feature 1",
            "Feature 2",
            "Feature 3"
        ],
        images: [.init(.placeholder), .init(.placeholder), .init(.placeholder)]
    )
}
