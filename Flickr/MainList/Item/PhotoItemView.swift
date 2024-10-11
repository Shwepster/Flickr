//
//  PhotoItemView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import SwiftUI

struct PhotoItemView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                imageView(from: image)
                    .zIndex(1)
            } else {
                loadingView
                    .zIndex(2) // avoid using 0 index, it messes up animations
            }
            
            topBar.zIndex(3)
        }
        .clipShape(.rect(cornerRadius: 8))
        .animation(.easeInOut.speed(2), value: viewModel.image)
        .transition(.opacity)
        .task {
            await viewModel.onCreated()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var topBar: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    viewModel.onDelete()
                } label: {
                    Image(systemName: "trash")
                        .padding(10)
                        .background(Color.app.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(8)
                }
                .buttonStyle(.borderless)
            }
            
            Spacer()
        }
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
                    if viewModel.title.isNotEmpty {
                        title
                    }
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
    }
    
    @ViewBuilder
    private var title: some View {
        VStack {
            Spacer()
            Text(viewModel.title)
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.black.opacity(0.5))
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @StateObject var viewModel: PhotoItemView.ViewModel = .init(photo: .test)
    
    PhotoItemView(viewModel: viewModel)
        .aspectRatio(contentMode: .fit)
        .frame(height: 500)
}
