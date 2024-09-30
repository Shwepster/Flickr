//
//  AppStyle.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

import SwiftUI

enum AppStyle {
    static var background: Color { deepPurple }
    static var secondaryBackground: Color { lightPurple }
    
    static var deepPurple: Color {
        .purple.mix(with: .black, by: 0.5)
    }
    
    static var lightPurple: Color {
        .purple.mix(with: .black, by: 0.4)
    }
    
    static var navyBlue: Color {
        .blue.mix(with: .black, by: 0.5)
    }
}

extension Color {
    static var app: AppStyle.Type {
        AppStyle.self
    }
}
