//
//  ImageCacheService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

actor ImageCacheService {
    private let fileManager: FileManager = .default
    private let imageExtension = "jpg"
    
    func cache(image: UIImage, for id: String) {
        guard let cacheDirectory = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first, let data = image.jpegData(compressionQuality: 1) else { return }
        
        let fileURL = cacheDirectory.appendingPathComponent("\(id).\(imageExtension)")
        
        do {
            try data.write(to: fileURL)
            print("File saved to cache: \(fileURL.lastPathComponent)")
        } catch {
            print("Failed to save file: \(error)")
        }
    }
    
    func getImage(for id: String) -> UIImage? {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheFileURL = cacheDirectory.appendingPathComponent("\(id).\(imageExtension)")
        
        guard fileManager.fileExists(atPath: cacheFileURL.path) else { return nil }
        return UIImage(contentsOfFile: cacheFileURL.path)
    }
    
    func clearCache() {
        guard let cacheDirectory = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: nil
            )
            
            for fileURL in fileURLs where fileURL.pathExtension == imageExtension {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Failed to remove files: \(error)")
        }
    }
}
