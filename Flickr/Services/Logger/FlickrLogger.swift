//
//  FlickrLogger.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.10.2024.
//

import Foundation

protocol FlickrLogger: Sendable {
    func logEvent(_ event: Event)
}

final class LoggerDefault: FlickrLogger {
    func logEvent(_ event: Event) {
        print(event)
    }
}
