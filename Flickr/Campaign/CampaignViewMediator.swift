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
    var navigation = CurrentValueSubject<NavigationType?, Never>(nil)
    // left this as a reminder that marking closure @Sendable is important
    // because even without warning it can crash
    // var callback: (@Sendable () -> Void)?
    private var currentCampaign: Campaign?
    private var onCampaignDismiss: (@Sendable () -> Void)?
    
    @MainActor
    func showCampaign(_ campaign: Campaign, onDismiss: @Sendable @escaping () -> Void) {
        currentCampaign = campaign
        onCampaignDismiss = onDismiss
        
        let view = campaign.buildView()
        let route: Route = .init(screen: .campaign(view)) { [weak self] in
            self?.campaignDidEnd()
        }
        
        navigation.send(.pushOnTop(route))
    }
    
    @MainActor
    private func campaignDidEnd() {
        onCampaignDismiss?()
        onCampaignDismiss = nil
        currentCampaign = nil
    }
}
