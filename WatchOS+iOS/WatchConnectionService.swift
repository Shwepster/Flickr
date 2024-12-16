//
//  WatchConnectionService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 14.12.2024.
//

import Foundation
import WatchConnectivity
import Combine

#if os(iOS)
import BackgroundTasks
#endif

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
    
    func sendFile() {
        let session = WCSession.default
        
//        session.isReachable
        guard session.activationState == .activated else {
            print("session is not activated")
            return
        }
        
        #if os(iOS)
        guard session.isWatchAppInstalled else {
            print( "watch app not installed")
            return
        }
        #endif
        
        Task.detached(priority: .high) {
            let url = self.copyFileToWritableLocation(
                fileName: "Kuran Iglesias - Could I Have This Kiss Forever",
                fileExtension: "mp3"
            )
            
            guard let url else {
                print( "could not copy file")
                return
            }
            
            let message: [String: Any] = [WatchTransferKeys.file.rawValue: url.lastPathComponent]
            
            // test normal url
            let fileTransfer = session.transferFile(URL(fileURLWithPath: url.relativePath), metadata: message)
            
            print("File transfer initiated for: \(url.lastPathComponent)")
            
            // Monitor the progress of the file transfer
            fileTransfer.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
         
//            scheduleBackgroundTask()
        }
    }
    
#if os(watchOS)
//    func scheduleBackgroundTask() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.example.app.uploadTask")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 10) // Schedule it to begin in 15 seconds
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Failed to schedule background task: \(error)")
//        }
//    }
#endif
    // to maintain file progress completion, since right now, after iOS 17.5 & WatchOS 10.5 update,
    // there is an issue in the File transfer where the callback session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) did not fire at all and the file transfer gets stuck.
    // therefore, this function is made to handle the error.
    // read more on https://forums.developer.apple.com/forums/thread/751623?page=2
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted", let progress = object as? Progress {
            print("Transfer progress: \(progress.fractionCompleted * 100)%")
            
            if progress.fractionCompleted == 1.0 {
                // Transfer is complete
                print("File transfer completed successfully.")
                
                // Remove observer to prevent memory leaks
                progress.removeObserver(self, forKeyPath: "fractionCompleted")
            }
        }
    }
    
    private func copyFileToWritableLocation(fileName: String, fileExtension: String) -> URL? {
        // Locate the file in the bundle
        guard let bundleURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("File \(fileName).\(fileExtension) not found in the bundle.")
            return nil
        }
        
        // Define the destination in the temporary directory
        let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // try this
//        let tempDirectory = FileManager.default.temporaryDirectory
        let destinationURL = tempDirectory.appendingPathComponent("\(fileName).\(fileExtension)")
        
        // Copy the file to the writable directory
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
 
            try FileManager.default.copyItem(at: bundleURL, to: destinationURL)
        } catch {
            print("Error copying file: \(error)")
            return nil
        }
        
        return destinationURL
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Did receive message from watch: \(message)")
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Did receive file from watch: \(file)")
        
        
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("watchsong.mp3")
        print("Saving file to: \(destinationURL.path)")
        
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: destinationURL)
            print("File moved successfully to: \(destinationURL.path)")
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: (any Error)?) {
        print("file transfer finished")
        print(error?.localizedDescription ?? "")
        print(fileTransfer.file)
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
