//
//  ListView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 28.10.2024.
//

import SwiftUI

struct ListView: View {
    var photoViewModels: [PhotoItemView.ViewModel]
    let onRefresh: () async -> Void
    let onPaginate: () async -> Void
    let state: PhotoListViewModel.State
    
    var body: some View {
        List {
            ForEach(photoViewModels, id: \.id) { viewModel in
                PhotoItemView(viewModel: viewModel, contentMode: .fill)
                    .aspectRatio(1/1, contentMode: .fit)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.app.background)
            
            loadingItem
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.app.background)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.app.backgroundGradient)
        .animation(.easeInOut.speed(2), value: photoViewModels)
        .refreshable {
            await onRefresh()
        }
    }
    
    // MARK: - Views
    @ViewBuilder
    private var loadingItem: some View {
        switch state {
        case .loading:
            progressView
                .frame(height: 50, alignment: .center)
        case .idle:
            Color.clear
                .onAppear {
                    Task {
                        await onPaginate()
                    }
                }
        case .allPagesLoaded:
            EmptyView()
        case .error(let error):
            errorView(error: error)
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        ProgressView()
            .scaleEffect(1.5)
            .progressViewStyle(CircularProgressViewStyle())
            .id(UUID())
    }
    
    @ViewBuilder
    private func errorView(error: String) -> some View {
        VStack(spacing: 12) {
            Text(error)
                .font(.subheadline)
            Text("Tap to retry")
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 100)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .frame(height: photoViewModels.isEmpty ? UIScreen.main.bounds.height : 100)
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                await onRefresh()
            }
        }
    }
}
