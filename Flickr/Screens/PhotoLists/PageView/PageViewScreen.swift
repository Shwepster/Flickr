//
//  PageViewScreen.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.10.2024.
//

import SwiftUI

struct PageViewScreen: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        PageView(photoViewModels: viewModel.photoViewModels) {
            await viewModel.onPaginate()
        }
        .swipeToDismiss()
        .bindToNavigation(viewModel.$navigation)
        .task {
            await viewModel.onCreate()
        }
    }
}

#Preview {
    PageViewScreen()
}
