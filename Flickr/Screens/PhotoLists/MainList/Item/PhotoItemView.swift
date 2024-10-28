//
//  PhotoItemView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import SwiftUI

struct PhotoItemView: View {
    @ObservedObject var viewModel: ViewModel
    let contentMode: ContentMode
    
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
                        .barImageModifier()
                }
                .buttonStyle(.borderless)
                .tint(.app.tint)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func imageView(from image: Image) -> some View {
        GeometryReader { geometry in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .background(.app.lightPurple)
                .overlay(alignment: .bottom) {
                    if viewModel.title.isNotEmpty {
                        title
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.onSelect()
                }
                .onLongPressGesture {
                    viewModel.onEdit()
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
                .padding(10)
                .background(.black.opacity(0.5))
        }
    }
}

// MARK: - Image modifier

fileprivate extension Image {
    func barImageModifier() -> some View {
        self.padding(10)
            .background(.app.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(8)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @StateObject var viewModel: PhotoItemView.ViewModel = .init(
        photo: .init(photo: .test, image: .init(.placeholder))
    )
    
    PhotoItemView(viewModel: viewModel, contentMode: .fill)
        .aspectRatio(contentMode: .fit)
        .frame(height: 500)
}
