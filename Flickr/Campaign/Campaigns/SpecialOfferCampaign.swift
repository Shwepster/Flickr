//
//  SpecialOfferCampaign.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

import Combine
import SwiftUI

final class SpecialOfferCampaign: Campaign, @unchecked Sendable {
    static let events: Set<String> = [Event.special.rawValue, Event.search.rawValue]
    static let priority: Int = 3
    
    let state: CurrentValueSubject<CampaignState, Never> = .init(.inactive)
    @ServiceLocator(.singleton) private var campaignMediator: CampaignViewMediator

    deinit {
        print("Special offer campaign deinitialized")
    }
    
    func start(triggeredBy event: String) {
        state.value = .active
        print("Special offer campaign started")
        
        Task { @MainActor in
            campaignMediator.showCampaign(self) { [weak self] in
                print("Special offer campaign ended")
                self?.state.value = .ended
            }
        }
    }
    
    @ViewBuilder
    func buildView() -> any View {
        Color.yellow
            .overlay {
                Text("Promo campaign")
                    .foregroundStyle(.black)
            }
    }
}
