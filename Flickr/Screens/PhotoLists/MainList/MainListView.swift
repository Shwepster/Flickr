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
        content
            .toolbar {
                Button {
                    withAnimation(.easeInOut) {
                        viewModel.toggleViewType()
                    }
                } label: {
                    Image(
                        systemName: viewModel.isPageView
                        ? "square.split.2x1.fill"
                        : "square.split.1x2.fill"
                    )
                }

            }
            .task {
                await viewModel.onCreate()
            }
            .sheet(item: $viewModel.editingViewModel) { viewModel in
                EditorView(viewModel: viewModel)
                    .presentationDetents(.init([.fraction(0.7)]))
            }
            .alert(isPresented: $viewModel.errorModel.isErrorPresented, error: viewModel.errorModel.errorMessage) {
                Button("Retry") {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isPageView {
            PageView(photoViewModels: viewModel.photoViewModels, onPaginate: viewModel.onPaginate)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            ListView(
                photoViewModels: viewModel.photoViewModels,
                onRefresh: viewModel.refresh,
                onPaginate: viewModel.onPaginate,
                state: viewModel.state
            )
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    NavigationView {
        MainListView(viewModel: .init())
    }
}
