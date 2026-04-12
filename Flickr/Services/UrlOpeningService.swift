//
//  UrlOpeningService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 17.10.2024.
//

import UIKit

enum UrlOpeningService {
    @MainActor
    static func openUrl(withPath path: String) {
        guard let url = URL(string: path) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
