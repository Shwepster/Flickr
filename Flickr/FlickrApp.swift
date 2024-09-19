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
                Task(priority: .high) {
                    await testApi()
                }
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
        
        let service = AppServices.shared.photoService
        
        await withTaskGroup(of: Void.self) { group in
            for photo in result.photo + result.photo + result.photo {
                group.addTask {
                    let image = await service.loadImage(for: photo, size: AppSettings.photoSize)
                    print("image: \(photo.id) - \(image?.size)")
                }
            }
            
            for photo in result.photo {
                service.cancelPhotoLoading(for: photo)
            }
        } 
    } catch {
        print(error)
    }
}
