//
//  EditorView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 11.10.2024.
//

import SwiftUI

struct EditorView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Color.white
                .opacity(0.1)
                .overlay {
                    viewModel.editedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.onModify()
                }
            
            buttons
        }
        .padding(.vertical)
        .background(Color.app.background)
    }
    
    @ViewBuilder private var buttons: some View {
        Button {
            viewModel.onSave()
        } label: {
            Text("Save")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.bordered)
        .controlSize(.mini)
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @StateObject var viewModel: EditorView.ViewModel = .init(
        photoViewModel: PhotoItemView.ViewModel(
            photo: .test
        )
    )

    EditorView(viewModel: viewModel)
        .frame(height: 500)
}
