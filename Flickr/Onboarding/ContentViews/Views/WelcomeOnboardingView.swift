//
//  WelcomeOnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct WelcomeOnboardingView: View {
    let welcomeText: String
    
    var body: some View {
        Text(welcomeText)
            .font(.largeTitle)
            .bold()
            .shadow(radius: 10)
    }
}

#Preview {
    WelcomeOnboardingView(welcomeText: "Welcome to Flickr!")
}
