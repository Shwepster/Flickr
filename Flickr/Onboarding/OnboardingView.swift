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
            
            content
            Spacer()
            
            OnboardingButton(
                onTap: { viewModel.onContinueTapped() },
                buttonState: viewModel.buttonState
            )
            .padding(.bottom, 40)
        }
        .padding()
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
        OnboardingContentFabric.makeView(for: viewModel.currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.push(from: dragController.draggedFromSide))
            .animation(.smooth, value: viewModel.currentPage)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !dragController.isDragging else { return }
                dragController.startDrag(value.translation)
                let dragAnimationDuration = 0.8
                
                withAnimation(.easeInOut(duration: dragAnimationDuration)) {
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
        datasource: OnboardingView.OnboardingDatasourceNew()
    )
    
    OnboardingView(viewModel: viewModel)
}
