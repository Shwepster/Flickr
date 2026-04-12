//
//  PromoCampaign.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

import Combine
import SwiftUI

final class PromoCampaign: Campaign, @unchecked Sendable {
    static let priority: Int = 1
    static let events: Set<String> = [Event.promo.rawValue, Event.search.rawValue]
    
    let state: CurrentValueSubject<CampaignState, Never> = .init(.inactive)
    @ServiceLocator(.singleton) private var campaignMediator: CampaignViewMediator

    deinit {
        print("Promo campaign deinit")
    }
    
    func start(triggeredBy event: String) {
        state.value = .active
        print("Promo campaign started")
        
        Task { @MainActor in
            campaignMediator.showCampaign(self) { [weak self] in
                print("Promo campaign ended")
                self?.state.value = .ended
            }
        }
    }
    
    func canBeShown() -> Bool {
        false
    }
    
    @ViewBuilder
    func buildView() -> any View {
        Color.blue
    }
}
