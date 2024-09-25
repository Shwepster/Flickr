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
                AppServicesRegistrator.registerAllServices()
                
                Task(priority: .high) {
                    await testApi()
                }
            }
        }
    }
}

func testApi() async {
    do {
        @ServiceLocator var flickrService: FlickrService
        
        let result = try await flickrService.search(
            for: "cat",
            page: 1,
            perPage: AppSettings.photosPerPage
        )
        
        @ServiceLocator var photoService: PhotoService
        
        await withTaskGroup(of: Void.self) { [photoService] group in
            for photo in result.photo {
                group.addTask {
                    let image = await photoService.loadImage(for: photo, size: AppSettings.photoSize)
                    print("image: \(photo.id) - \(image?.size)")
                }
            }
            
            for photo in result.photo {
                photoService.cancelPhotoLoading(for: photo)
            }
        } 
    } catch {
        print(error)
    }
}
