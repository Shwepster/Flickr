//
//  MainListView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import SwiftUI

struct MainListView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.photos, id: \.iterationId) { photo in
                PhotoItemView(photo: photo)
                    .aspectRatio(1/1, contentMode: .fit)
            }
            .listRowBackground(Color.app.background)
            .listRowSeparator(.hidden)
            
            loadingItem
                .listRowBackground(EmptyView())
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.app.background)
    }
    
    @ViewBuilder
    private var progressView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(2)
                .progressViewStyle(CircularProgressViewStyle())
                .tint(.white)
            Spacer()
        }
    }
    
    @ViewBuilder
    private var loadingItem: some View {
        switch viewModel.state {
        case .loading:
            progressView
        case .idle:
            progressView
                .onAppear {
                    viewModel.onPaginate()
                }
        case .allPagesLoaded:
            EmptyView()
        case .error(let error):
            Text(error)
                .onTapGesture {
                    viewModel.search()
                }
        }
    }
}

#Preview {
    MainListView()
}
