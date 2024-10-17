//
//  OnboardingBottomView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 17.10.2024.
//

import SwiftUI

struct OnboardingBottomView: View {
    let texts: [String]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(texts) { text in
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingBottomView(texts: ["SwiftUI", "Flickr", "iOS"])
}
