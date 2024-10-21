//
//  Campaign.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

import Combine
import SwiftUI

protocol Campaign {
    static var events: Set<String> { get }
    static var priority: Int { get }
    static var name: String { get }
    var state: CurrentValueSubject<CampaignState, Never> { get }
    func canBeShown() -> Bool
    func start(triggeredBy event: String)
    func buildView() -> any View
}

extension Campaign {
   static var name: String {
       String(describing: Self.self)
    }
    
    func canBeShown() -> Bool {
        true
    }
}

enum CampaignState {
    case inactive
    case active
    case ended
}
