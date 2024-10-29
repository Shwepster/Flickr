//
//  MainListViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import Foundation

extension MainListView {
    final class ViewModel: PhotoListViewModel {
        @Published var isPageView = false
        
        func toggleViewType() {
            isPageView.toggle()
        }
        
        override func createViewModels(from models: [PhotoModel]) -> [PhotoItemView.ViewModel] {
            models.map {
                PhotoItemView.ViewModel(photo: $0) { [weak self] viewModel in
                    self?.deletePhoto(viewModel: viewModel)
                } onEdit: { [weak self] viewModel in
                    self?.showEdit(for: viewModel)
                } onSelect: { [weak self] viewModel in
                    self?.showEdit(for: viewModel)
                }
            }
        }
        
        // MARK: - Private
        private func showEdit(for viewModel: PhotoItemView.ViewModel) {
            let route = Route(
                screen: .editPhoto(viewModel.photo),
                settings: .init(presentationDetents: [.fraction(0.7)])
            )
            navigation = .present(route)
        }
    }
}
