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
        NavigationView {
            ScrollView {
                if viewModel.items.isEmpty {
                    emptyView
                } else {
                    ForEach(viewModel.items) { item in
                        Text(item.text)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(.fill)
                            .clipShape(.capsule)
                            .contentShape(Capsule())
                            .onLongPressGesture {
                                viewModel.deleteItem(item)
                            }
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: viewModel.items)
                }
            }
            .background(Color.black)
            .ignoresSafeArea(.all, edges: .bottom)
            .task {
                viewModel.onCreated()
            }
            .navigationTitle("Flickr History")
        }
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
