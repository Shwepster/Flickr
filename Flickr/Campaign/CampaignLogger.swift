//
//  CampaignLogger.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

import Foundation

/// Passes events to trigger campaings
final class CampaignLogger: FlickrLogger {
    private let campaignManager = CampaignManager()
    private let logger: FlickrLogger
    
    init(logger: FlickrLogger) {
        self.logger = logger
    }
    
    func logEvent(_ event: Event) {
        Task { [campaignManager] in
            await campaignManager.handleEvent(event.rawValue)
        }
        logger.logEvent(event)
    }
}
