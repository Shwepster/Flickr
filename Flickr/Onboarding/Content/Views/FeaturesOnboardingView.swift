//
//  FeaturesOnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct FeaturesOnboardingView: View {
    let features: [String]
    
    var body: some View {
        VStack {
            ForEach(features) { feature in
                Text(feature)
            }
            .foregroundStyle(.secondary)
            .font(.headline)
            .italic()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.app.barBackground.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
        Spacer()
    }
}

#Preview {
    FeaturesOnboardingView(features: ["SwiftUI", "Combine", "UIKit"])
}
