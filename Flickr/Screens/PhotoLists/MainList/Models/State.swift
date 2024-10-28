//
//  State.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 21.10.2024.
//

extension PhotoListViewModel {
    enum State: Equatable {
        case loading
        case idle
        case allPagesLoaded
        case error(String)
    }
}
