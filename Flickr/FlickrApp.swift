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
        
        let service = PhotoServiceCropped(
            cropSize: .init(width: 128, height: 128),
            photoService: AppServices.shared.photoService
        )
        
        await withTaskGroup(of: Void.self, body: { group in
            for photo in result.photo[..<10] {
                group.addTask {
                    let image = await service.loadImage(for: photo)
                    print(image?.size)
                }
            }
            
            for photo in result.photo[..<10] {
                service.cancelPhotoLoading(for: photo)
            }
        })
    } catch {
        print(error)
    }
}
