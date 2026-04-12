//
//  ErrorModel.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

extension PhotoListViewModel {
    struct ErrorModel {
        var isErrorPresented = false {
            didSet {
                if oldValue == true, isErrorPresented == false {
                    errorMessage = nil
                }
            }
        }
        
        private(set) var errorMessage: String?
        
        mutating func presentError(_ error: String) {
            errorMessage = error
            isErrorPresented = true
        }
    }
}
