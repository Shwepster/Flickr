//
//  SearchableMainListView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 30.09.2024.
//

import SwiftUI

struct SearchableMainListView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            MainListView(viewModel: viewModel.listViewModel)
                .searchable(text: $viewModel.searchText, prompt: "Search for photos")
                .searchFocused($isFocused)
                .onSubmit(of: .search) { search() }
                .navigationTitle("Flickr")
                .overlay {
                    if isFocused {
                        suggestionsView
                    }
                }
                .animation(.easeInOut.speed(2), value: isFocused)
        }
        .background(.app.backgroundGradient)
        .tint(.app.tint)
        .onAppear { viewModel.onAppear() }
    }
    
    @ViewBuilder
    private var suggestionsView: some View {
        VStack {
            if viewModel.history.isEmpty {
                emptyHistoryView
            } else {
                VStack {
                    ForEach(viewModel.history, id: \.id) { item in
                        historyView(item)
                    }
                }
                .padding()
                
                clearHistoryButton
            }
            
            Spacer()
        }
        .background(.app.background)
        .animation(.easeInOut, value: viewModel.history)
        .onTapGesture {
            cancelFocus()
        }
    }
    
    @ViewBuilder
    private var clearHistoryButton: some View {
        Button {
            viewModel.clearHistory()
        } label: {
            Text("Clear history")
                .padding()
                .frame(maxWidth: .infinity)
                .background(.app.secondaryBackground)
        }
    }
    
    @ViewBuilder
    private var emptyHistoryView: some View {
        Text("No history yet")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
    }
    
    @ViewBuilder
    private func historyView(_ item: HistoryItem) -> some View {
        HStack {
            Text(item.text)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                viewModel.deleteItem(item)
            } label: {
                Image(systemName: "trash")
            }
        }
        .padding(6)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.searchText = item.text
            search()
        }
    }
    
    // MARK: - Helpers
    
    private func search() {
        viewModel.search()
        cancelFocus()
    }
    
    private func cancelFocus() {
        isFocused = false
        
        if isFocused {
            isFocused = false
        }
    }
}

#Preview {
    SearchableMainListView()
}
