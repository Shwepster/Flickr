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
            Text(viewModel.currentPage.title)
                .font(.title)
                .bold()
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
        .gesture(dragGesture)
    }
    
    @ViewBuilder
    private var content: some View {
        OnboardingContentFabric.makeContent(for: viewModel.currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.push(from: dragController.draggedFromSide))
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
                guard !dragController.isDragging else { return }
                dragController.startDrag(value.translation)
                
                withAnimation(.smooth) {
                    if dragController.isLeft {
                        viewModel.didDragLeft()
                    } else if dragController.isRight {
                        viewModel.didDragRight()
                    }
                } completion: {
                    dragController.endDrag()
                }
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
