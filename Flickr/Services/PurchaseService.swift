//
//  PurchaseService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 16.11.2024.
//

import Combine

final class PurchaseService: @unchecked Sendable {
    private(set) var isPurchased = CurrentValueSubject<Bool, Never>(false)
    @ServiceLocator(.singleton) private var logger: FlickrLogger
    
    @MainActor
    func purchase() async throws(PurchaseError) {
        do {
            // imitate purchase
            try await Task.sleep(for: .seconds(1))
            isPurchased.value = true
            logger.logEvent(.purchaseCompleted)
        } catch {
            throw .unknown
        }
    }
}

extension PurchaseService {
    enum PurchaseError: Error {
        case unknown
    }
}
