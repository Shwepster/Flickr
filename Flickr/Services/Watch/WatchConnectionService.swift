//
//  WatchConnectionService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 14.12.2024.
//

import Foundation
import WatchConnectivity
import Combine

final class WatchConnectionService: NSObject, @unchecked Sendable {
    private(set) var watchState: CurrentValueSubject<WCSessionActivationState?, Never>
    private(set) var userInfoPublisher: PassthroughSubject<[String: Any], Never> = .init()
    
    override init() {
        watchState = .init(nil)
        super.init()
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            watchState = .init(WCSession.default.activationState)
        } else {
            print("watch session not supported")
        }
    }
    
    func sendHistory(_ history: [HistoryItem]) {
        let session = WCSession.default
        
        guard session.activationState == .activated, session.isReachable else {
            print("app not installed")
            return
        }
        do {
            let data = try JSONEncoder().encode(history)
            session.transferUserInfo([WatchTransferKeys.history.rawValue: data])
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension WatchConnectionService: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        print("started watch session")
        print(activationState)
        print(error?.localizedDescription ?? "")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        userInfoPublisher.send(userInfo) // this is on background thread
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("watch session became inactive")
        watchState.send(session.activationState)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("watch session deactivated")
        watchState.send(session.activationState)
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("watch state changed")
        watchState.send(session.activationState)
    }
#endif
}
