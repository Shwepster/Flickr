//
//  OnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: ViewModel
    @State private var dragController: DragController
    
    init(viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
        
        let dragController = DragController { edge in
            edge == .leading
            ? viewModel.didDragForward()
            : viewModel.didDragBack()
        }
        _dragController = .init(wrappedValue: dragController)
    }
    
    var body: some View {
        VStack {
            OnboardingContentFabric.makeTitle(for: viewModel.currentPage)
                .id(viewModel.currentPage.title)
            
            content
            
            VStack(spacing: 16) {
                OnboardingButton(
                    onTap: viewModel.continueAction,
                    buttonState: viewModel.buttonState
                )
                .padding(.horizontal)
                
                bottomContent
                    .frame(height: 25)
            }
            .padding()
        }
        .padding(.vertical)
        .background {
            Image(.placeholder)
                .resizable()
                .scaledToFill()
                .blur(radius: 10)
                .overlay {
                    Color.app.backgroundGradient
                        .opacity(0.96)
                }
                .ignoresSafeArea()
        }
        .animation(.bouncy(duration: 0.6), value: viewModel.currentPage)
        .gesture(dragGesture, isEnabled: viewModel.buttonState != .loading)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var content: some View {
        OnboardingContentFabric.makeContent(for: viewModel.currentPage)
            .id(viewModel.currentPage)
            .containerRelativeFrame(.horizontal)
            .frame(maxHeight: .infinity)
            .offset(x: dragController.translation)
            .transition(.push(from: dragController.dragDirection.opposite))
            .animation(.bouncy(duration: 0.6), value: dragController.translation)
    }
    
    @ViewBuilder
    private var bottomContent: some View {
        OnboardingContentFabric
            .makeBottomContent(
                for: viewModel.currentPage,
                termsAction: viewModel.termsAction,
                conditionsAction: viewModel.conditionsAction,
                restoreAction: viewModel.restoreAction
            )
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragController.onDragChange(value.translation)
            }
            .onEnded { _ in
                dragController.onDragEnd()
            }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = OnboardingView.ViewModel(
        dataSource: OnboardingView.OnboardingDatasourceDefault()
    )
   
    OnboardingView(viewModel: viewModel)
}

#Preview {
    @Previewable @StateObject var viewModel = OnboardingView.ViewModel(
        dataSource: OnboardingView.OnboardingDatasourceNew()
    )
    
    OnboardingView(viewModel: viewModel)
}
