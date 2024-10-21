//
//  EditorView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 11.10.2024.
//

import SwiftUI

struct EditorView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            editorImage
            slider
            buttons
        }
        .padding()
        .background(.app.background)
        .onChange(of: viewModel.needsDismiss) {
            dismiss()
        }
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
    
    @ViewBuilder
    private var slider: some View {
        HStack {
            Slider(value: $viewModel.hueRotation, in: viewModel.angleRange)
            Text(viewModel.hueRotation.rounded().formatted())
                .monospaced()
                .frame(width: 40, alignment: .center)
        }
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
