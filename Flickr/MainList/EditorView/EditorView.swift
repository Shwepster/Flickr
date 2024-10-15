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
            editorImage
            HStack {
                Slider(value: $viewModel.hueRotation, in: viewModel.angleRange)
                Text(viewModel.hueRotation.rounded().formatted())
                    .monospaced()
                    .frame(width: 40, alignment: .center)
            }

            buttons
        }
        .padding()
        .background(Color.app.background)
    }
    
    @ViewBuilder
    private var editorImage: some View {
        Color.white
            .opacity(0.1)
            .overlay {
                viewModel.editedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .hueRotation(.degrees(viewModel.hueRotation))
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private var buttons: some View {
        Button {
            viewModel.onSave()
        } label: {
            Text("Save")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.bordered)
        .controlSize(.mini)
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
