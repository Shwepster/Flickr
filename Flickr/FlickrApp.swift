//
//  FlickrApp.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

import SwiftUI

@main
struct FlickrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                await testApi()
            }
        }
    }
}

func testApi() async {
    do {
        let result = try await AppServices.shared.flickrService.search(
            for: "cat",
            page: 1,
            perPage: AppSettings.photosPerPage
        )
        
        let imageData = try await AppServices.shared.flickrService.loadImage(
            for: result.photo[0],
            size: AppSettings.photoSize
        )
        
        let image = UIImage(data: imageData)
        print(image)
    } catch {
        print(error)
    }
}
