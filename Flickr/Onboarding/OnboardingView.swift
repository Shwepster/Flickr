//
//  OnboardingView.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 15.10.2024.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.currentPage.title)
                .font(.title)
                .bold()
            content
            Spacer()
            button
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
    }
    
    @ViewBuilder
    private var content: some View {
        OnboardingContentFabric.makeView(for: viewModel.currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(
                .push(from: .trailing)
            )
            .animation(.smooth, value: viewModel.currentPage)
    }
    
    @ViewBuilder
    private var button: some View {
        Button {
            withAnimation {
                viewModel.onContinueTapped()
            }
        } label: {
            HStack(spacing: 0) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.secondary)
                    .scaleEffect(0.8)
                    .padding(.trailing, -16)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    .hidden(viewModel.buttonState != .loading)

                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
                
                Color.clear
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 0)
                    .hidden()
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(.app.lightPurple)
        .shadow(color: .app.extraLightPurple.opacity(0.1), radius: 16)
    }
    
    private var buttonTitle: String {
        switch viewModel.buttonState {
        case .continue:
            "Continue"
        case .purchase:
            "Purchase"
        case .loading:
            "Loading"
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = OnboardingView.ViewModel(
        datasource: OnboardingView.OnboardingDatasourceNew()
    )
    
    OnboardingView(viewModel: viewModel)
}
