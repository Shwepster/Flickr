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
    
    func sendFile(url: URL) {
        let session = WCSession.default
        
        guard session.activationState == .activated, session.isReachable else {
            print("app not installed")
            return
        }
        
        guard let filePath = Bundle.main.path(
            forResource: "Kuran Iglesias - Could I Have This Kiss Forever",
            ofType: "mp3"
        ) else {
            print("MP3 file not found!")
            return
        }
        let url = URL(filePath: filePath)
        
        Task.detached(priority: .high) {
            // load file and send
            let fileData = try? Data(contentsOf: url)
            guard let fileData else { return }
            do {
                let message: [String: Any] = [WatchTransferKeys.file.rawValue: fileData]
                session.sendMessage(message) { dict in
                    print("reply: \(dict)")
                } errorHandler: { error in
                    print("reply error: \(error.localizedDescription)")
                }
                //            try session.transferFile(<#T##file: URL##URL#>, metadata: <#T##[String : Any]?#>)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#if os(iOS)
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Did receive message from watch: \(message)")
    }

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
}
#endif

#if os(watchOS)
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Did receive message from iPhone: \(message)")
    }
}
#endif
