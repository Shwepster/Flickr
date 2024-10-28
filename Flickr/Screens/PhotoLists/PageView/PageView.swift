//
//  PageView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

import SwiftUI

struct PageView: View {
    @State private var currentPhoto: PhotoItemView.ViewModel?
    let photoViewModels: [PhotoItemView.ViewModel]
    let onPaginate: () async -> Void
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(photoViewModels) { photo in
                        view(for: photo)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(20)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
//            .ifLet(currentPhoto) { view, photo in
//                view.onChange(of: photo) { oldValue, newValue in
//                    scrollProxy.scrollTo(newValue.id)
//                }
//            }
        }
        .background(.app.backgroundGradient)
        .swipeToDismiss()
        .task {
            currentPhoto = photoViewModels.first
        }
        .onAppear {
            Task {
                await onPaginate()
            }
        }
    }
    
    @ViewBuilder
    private func view(for photo: PhotoItemView.ViewModel) -> some View {
        PhotoItemView(viewModel: photo, contentMode: .fit)
            .id(photo.id)
            .containerRelativeFrame(
                .horizontal, count: 1, span: 1, spacing: 0
            )
            .frame(maxHeight: .infinity)
            .background(.app.secondaryBackground)
            .foregroundStyle(.white)
            .contentShape(Rectangle())
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scrollTransition(axis: .horizontal) { effect, phase in
                effect.scaleEffect(phase.isIdentity ? 1 : 0.95)
            }
            .onScrollVisibilityChange { isVisible in
                if isVisible {
                    currentPhoto = photo
                }
            }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = PageView.ViewModel()
    PageView(photoViewModels: viewModel.photoViewModels, onPaginate: viewModel.onPaginate)
}
