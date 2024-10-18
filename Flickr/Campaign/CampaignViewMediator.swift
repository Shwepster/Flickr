//
//  CampaignViewMediator.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

@preconcurrency import Combine
import SwiftUI

/// Responsible for creating `View` for `Campaign` and managing its presentation
final class CampaignViewMediator: @unchecked Sendable {
    let campaignSubject = PassthroughSubject<Campaign, Never>()
    // left this as a reminder that marking closure @Sendable is important
    // var callback: (@Sendable () -> Void)?
    private var currentCampaign: Campaign?
    private var onCampaignDismiss: (@Sendable () -> Void)?
    
    @MainActor
    func showCampaign(_ campaign: Campaign, onDismiss: @Sendable @escaping () -> Void) {
        currentCampaign = campaign
        onCampaignDismiss = onDismiss
        campaignSubject.send(campaign)
    }
    
    @MainActor
    func campaignDidEnd() {
        onCampaignDismiss?()
        onCampaignDismiss = nil
        currentCampaign = nil
    }
    
    @MainActor
    func getView() -> (any View)? {
        currentCampaign?.buildView()
    }
}
