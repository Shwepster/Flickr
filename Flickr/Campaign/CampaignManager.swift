//
//  CampaignManager.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

import Combine

/// Manages starting/ending of campaign
actor CampaignManager {
    private lazy var campaignStorage = CampaignStorage()
    private var activeCampaign: Campaign?
    private var cancellables: Set<AnyCancellable> = []
    
    func handleEvent(_ event: String) {
        guard activeCampaign == nil,
              let campaign = campaignStorage.createCampaign(for: event)
        else { return }
        
        if campaign.canBeShown() {
            activeCampaign = campaign
            campaign.start(triggeredBy: event)
            listenToCampaignState(campaign: campaign)
        }
    }
    
    private func removeActiveCampaign() {
        activeCampaign = nil
        cancellables.removeAll()
    }
    
    private func listenToCampaignState(campaign: Campaign) {
        campaign.state.sink { [weak self] state in
            Task { [self] in
                if state == .ended {
                    await self?.removeActiveCampaign()
                }
            }
        }.store(in: &cancellables)
    }
}
