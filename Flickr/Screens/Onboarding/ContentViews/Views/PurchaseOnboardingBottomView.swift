//
//  PurchaseOnboardingBottomView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 17.10.2024.
//

import SwiftUI

struct PurchaseOnboardingBottomView: View {
    let termsAction: () -> Void
    let conditionsAction: () -> Void
    let restoreAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button("Terms", action: termsAction)
            Button("Conditions", action: conditionsAction)
            Button("Restore", action: restoreAction)
        }
        .font(.caption)
    }
}

#Preview {
    PurchaseOnboardingBottomView(
        termsAction: {},
        conditionsAction: {},
        restoreAction: {}
    )
}
