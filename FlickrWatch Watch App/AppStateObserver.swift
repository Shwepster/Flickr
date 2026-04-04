//
//  AppStateObserver.swift
//  FlickrWatch Watch App
//
//  Created by Maxim Vynnyk on 16.12.2024.
//

import Foundation
import WatchKit

final class AppStateObserver {
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleEnterBackground),
                                               name: WKExtension.applicationDidEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleBecameActive),
                                               name: WKExtension.applicationDidBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWillClose),
                                               name: WKExtension.applicationWillResignActiveNotification,
                                               object: nil)
    }
    
    @objc private func handleBecameActive(_ notification: Notification) {
        print(">>> AppStateObserver: handleBecameActive")
    }
    
    @objc private func handleEnterBackground(_ notification: Notification) {
        print(">>> AppStateObserver: handleEnterBackground")
    }
    
    @objc private func handleWillClose(_ notification: Notification) {
        print(">>> AppStateObserver: handleWillClose")
    }
}

final class HTTPClient: NSObject {
    var session: URLSession!
    let requestBuilder = FlickrRequestBuilder(key: "b7917a20194fc79dba8a380f76a12e0f")
    
    override init() {
        super.init()
    
    }
    
    private func setup() {
        print("setup")
        let configuration = URLSessionConfiguration.background(withIdentifier: "mayapp")
        configuration.sessionSendsLaunchEvents = true
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func sendRequest() {
        if session == nil { setup() }
        
        print("sendRequest")
        let request = requestBuilder.search(query: "Cat", page: 1, perPage: 20, maxUploadDate: Date())
        let task = session.dataTask(with: request)
        task.resume()
    }
}

extension HTTPClient: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        print("Task created: \(task)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        print("Task completed: \(task)")
        
        if error == nil {
            sendRequest()
        }
    }
}
