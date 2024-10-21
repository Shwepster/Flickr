//
//  PageView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

import SwiftUI

struct PageView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(viewModel.photos) { photo in
                        view(for: photo)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(20)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .onAppear {
                if let photo = viewModel.currentPhoto {
                    scrollProxy.scrollTo(photo.id)
                }
            }
        }
        .background(.clear)
        .swipeToDismiss()
    }
    
    @ViewBuilder
    private func view(for photo: PhotoItemView.ViewModel) -> some View {
        if let image = photo.image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .containerRelativeFrame(
                    .horizontal, count: 1, span: 1, spacing: 0
                )
                .frame(maxHeight: .infinity)
                .background(.app.backgroundGradient)
                .foregroundStyle(.white)
                .contentShape(Rectangle())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .id(photo.id)
                .scrollTransition(axis: .horizontal) { effect, phase in
                    effect.scaleEffect(phase.isIdentity ? 1 : 0.95)
                }
                .onScrollVisibilityChange { isVisible in
                    if isVisible {
                        viewModel.currentPhoto = photo
                    }
                }
                .onTapGesture(perform: viewModel.onTap)
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = PageView.ViewModel(
        initialPhoto: nil,
        photos: PhotoDTO.testList.map {
            PhotoItemView.ViewModel(
                photo: $0
            )
        },
        onSelect: {_ in}
    )
    
    PageView(viewModel: viewModel)
        .task {
            viewModel.photos.forEach { vm in Task { await vm.onCreated() } }
        }
}
