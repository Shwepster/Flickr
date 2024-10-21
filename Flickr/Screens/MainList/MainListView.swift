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
            ForEach(viewModel.photoViewModels, id: \.id) { viewModel in
                PhotoItemView(viewModel: viewModel)
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
        .animation(.easeInOut.speed(2), value: viewModel.photoViewModels)
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(item: $viewModel.editingViewModel) { viewModel in
            let editorVM = EditorView.ViewModel(photoViewModel: viewModel)
            EditorView(viewModel: editorVM)
                .presentationDetents(.init([.fraction(0.7)]))
        }
        .fullScreenCover(item: $viewModel.pageViewModel) { pageViewModel in
            PageView(viewModel: pageViewModel)
                .presentationBackground(.ultraThinMaterial)
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
                .frame(height: 50, alignment: .center)
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
            errorView(error: error)
        }
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
        .frame(height: viewModel.photoViewModels.isEmpty ? UIScreen.main.bounds.height : 100)
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

#Preview {
    MainListView(viewModel: .init())
}
