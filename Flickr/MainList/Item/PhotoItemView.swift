//
//  PhotoItemView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import SwiftUI

struct PhotoItemView: View {
    @StateObject private var viewModel: ViewModel
    
    init(photo: PhotoDTO) {
        _viewModel = .init(wrappedValue: ViewModel(photo: photo))
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                imageView(from: image)
                    .zIndex(1)
            } else {
                loadingView
                    .zIndex(2) // avoid using 0 index, it messes up animations
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .animation(.easeInOut.speed(2), value: viewModel.image)
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func imageView(from image: Image) -> some View {
        GeometryReader { geometry in
            image
                .resizable(resizingMode: .tile)
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .background(Color.app.lightPurple)
                .overlay(alignment: .bottom) {
                    title
                }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        Color.app.lightPurple
            .overlay {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .task {
                await viewModel.onCreated()
            }
    }
    
    @ViewBuilder
    private var title: some View {
        VStack {
            Spacer()
            Text(viewModel.photo.title ?? "Default title")
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(.black.opacity(0.5))
        }
    }
}

#Preview {
    PhotoItemView(photo: .init(id: "1", owner: "2", secret: "3", server: "4", title: "5"))
        .aspectRatio(contentMode: .fit)
        .frame(height: 500)
}
