//
//  MainListViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 26.09.2024.
//

import Foundation

extension MainListView {
    final class ViewModel: PhotoListViewModel {
        @Published var editingViewModel: EditorView.ViewModel?
        @Published var pageViewModel: PageView.ViewModel?
        @Published var isPageView = true
                
        func toggleViewType() {
            isPageView.toggle()
        }
        
        override func createViewModels(from models: [PhotoModel]) -> [PhotoItemView.ViewModel] {
            models.map {
                PhotoItemView.ViewModel(photo: $0) { [weak self] viewModel in
                    self?.deletePhoto(viewModel: viewModel)
                } onEdit: { [weak self] viewModel in
                    self?.editingViewModel = .init(photo: viewModel.photo)
                } onSelect: { [weak self] viewModel in
                    guard let self else { return }
                    let pageViewModel = PageView.ViewModel()
                    pageViewModel.currentPhoto = viewModel
                    self.pageViewModel = pageViewModel
                }
            }
        }
    }
}
