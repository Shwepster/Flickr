//
//  HistoryView.swift
//  FlickrWatch Watch App
//
//  Created by Maxim Vynnyk on 13.12.2024.
//

import SwiftUI

struct HistoryView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            title
            
            if viewModel.items.isEmpty {
                emptyView
            } else {
                ForEach(viewModel.items) { item in
                    Text(item.text)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(.fill)
                        .clipShape(.capsule)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .background(Color.black)
        .ignoresSafeArea(.all, edges: .bottom)
        .task {
            viewModel.onCreated()
        }
    }
    
    @ViewBuilder
    private var title: some View {
        Text("Flickr Search History")
            .font(.headline)
            .padding(.bottom)
            .foregroundStyle(.primary.opacity(0.9))
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack {
            Text("No history yet")
                .padding()
                .foregroundStyle(.secondary)
                .font(.footnote)
            Button("Load History") {
                withAnimation {
                    viewModel.fillMockData()
                }
            }
            .buttonStyle(.automatic)
        }
        .padding(.top)
        .transition(.blurReplace)
    }
}

#Preview {
    HistoryView()
}
