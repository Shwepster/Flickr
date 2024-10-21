//
//  CampaignStorage.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

/// Manages `Campaign` creation via event-factory
struct CampaignStorage {
    typealias EventsMap = [String: [Campaign.Type]]
    typealias Factories = [String: () -> Campaign]
    private let eventsMap: EventsMap
    private let factories: Factories
    
    init() {
        let (eventsMap, factories) = CampaignStorage.createCampaigns()
        self.eventsMap = eventsMap
        self.factories = factories
    }
    
    func createCampaign(for event: String) -> Campaign? {
        guard let campaigns = eventsMap[event], campaigns.isNotEmpty else { return nil }
        
        var campaign = campaigns[0]
        campaigns.forEach {
            campaign = $0.priority < campaign.priority ? $0 : campaign
        }
        
        guard let factory = factories[campaign.name] else { return nil }
        return factory()
    }
    
    private static func createCampaigns() -> (EventsMap, Factories) {
        var eventsMap: EventsMap = [:]
        var factories: Factories = [:]
        
        func addCampaign(campaign: Campaign.Type, factory: @escaping @autoclosure () -> Campaign) {
            factories[campaign.name] = factory
            
            campaign.events.forEach { event in
                eventsMap[event, default: []].append(campaign)
            }
        }
        
        addCampaign(campaign: PromoCampaign.self, factory: PromoCampaign())
        addCampaign(campaign: SpecialOfferCampaign.self, factory: SpecialOfferCampaign())
        
        return (eventsMap, factories)
    }
}


