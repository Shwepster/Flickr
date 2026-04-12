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
        VStack(spacing: 20) {
            if features.isNotEmpty {
                FeaturesOnboardingView(features: features, images: images)
            } else {
                Spacer()
            }
            
            VStack {
                Spacer() //somehow this fixes all layout problems
                Image(.placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.app.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text("Purchase for only \(price.formatted(.currency(code: "USD")))")
                    .font(.title2)
                    .italic()
            }
            .padding(.horizontal)
        }
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
