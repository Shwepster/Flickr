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
        Group {
            if let image = viewModel.image {
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .overlay(alignment: .bottom) {
                            title
                        }
                }
            } else {
                Color.app.lightPurple
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .task {
            viewModel.onCreated()
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
