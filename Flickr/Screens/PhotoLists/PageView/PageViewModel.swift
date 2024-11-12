//
//  PageViewModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

import Foundation

extension PageViewScreen {
    @MainActor
    final class ViewModel: PhotoListViewModel, Identifiable {
        let id: String = UUID().uuidString
        var currentPhoto: PhotoItemView.ViewModel?
        @Published var scrollToId: String = ""
        @Published var editingViewModel: EditorView.ViewModel?
        
        override func onCreate() async {
            await super.onCreate()
            scrollToId = currentPhoto?.id ?? ""
        }
        
        override func createViewModels(from models: [PhotoModel]) -> [PhotoItemView.ViewModel] {
            models.map {
                PhotoItemView.ViewModel(photo: $0) { [weak self] viewModel in
                    self?.deletePhoto(viewModel: viewModel)
                } onEdit: { [weak self] viewModel in
                    self?.navigation = .push(.init(screen: .main))
                } onSelect: { [weak self] viewModel in
                    self?.navigation = .push(.init(screen: .editPhoto(viewModel.photo)))
                }
            }
        }
    }
}
