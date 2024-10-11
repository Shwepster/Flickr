//
//  MainListView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import SwiftUI

struct MainListView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.photos, id: \.id) { viewModel in
                PhotoItemView(viewModel: viewModel)
                    .aspectRatio(1/1, contentMode: .fit)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.app.background)
            
            loadingItem
                .frame(height: 50, alignment: .center)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.app.background)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.app.background)
        .animation(.easeInOut.speed(2), value: viewModel.photos)
        .refreshable {
            await viewModel.refresh()
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
    private var loadingItem: some View {
        switch viewModel.state {
        case .loading:
            progressView
        case .idle:
            Color.clear
                .onAppear {
                    Task {
                        await viewModel.onPaginate()
                    }
                }
        case .allPagesLoaded:
            EmptyView()
        case .error(let error):
            Text(error)
                .onTapGesture {
                    Task {
                        await viewModel.refresh()
                    }
                }
        }
    }
}

#Preview {
    MainListView(viewModel: .init())
}
