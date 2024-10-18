//
//  OnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: ViewModel
    @State private var dragController = DragController()
    
    init(viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            OnboardingContentFabric.makeTitle(for: viewModel.currentPage)
                .id(viewModel.currentPage.title)
            
            content
            
            OnboardingButton(
                onTap: viewModel.continueAction,
                buttonState: viewModel.buttonState
            )
            .padding()
            .padding(.horizontal)
            
            bottomContent
                .padding(.horizontal)
                .frame(height: 25)
        }
        .padding(.vertical)
        .background {
            Image(.placeholder)
                .resizable()
                .scaledToFill()
                .blur(radius: 10)
                .overlay {
                    Color.app.background
                        .opacity(0.9)
                }
                .ignoresSafeArea()
        }
        .animation(.smooth, value: viewModel.currentPage)
        .gesture(dragGesture)
    }
    
    @ViewBuilder
    private var content: some View {
        OnboardingContentFabric.makeContent(for: viewModel.currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.push(from: dragController.animationSide))
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
        DragGesture(minimumDistance: 15)
            .onChanged { value in
                guard !dragController.isDragging else { return }
                dragController.startDrag(value.translation)
                
                withAnimation(.smooth) {
                    dragController.dragDirection == .leading
                    ? viewModel.didDragForward()
                    : viewModel.didDragBack()
                }
            }
            .onEnded { _ in
                dragController.endDrag()
            }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = OnboardingView.ViewModel(
        datasource: OnboardingView.OnboardingDatasourceDefault()
    )
   
    OnboardingView(viewModel: viewModel)
}

#Preview {
    @Previewable @StateObject var viewModel = OnboardingView.ViewModel(
        datasource: OnboardingView.OnboardingDatasourceNew()
    )
    
    OnboardingView(viewModel: viewModel)
}
