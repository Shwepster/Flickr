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
        if !containsImage(for: id) {
            cacheWithReplacement(image: image, for: id)
        }
    }
    
    func cacheWithReplacement(image: UIImage, for id: String) {
        let url = url(for: id)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
                
        do {
            try data.write(to: url)
            print("File saved to cache: \(url.lastPathComponent)")
        } catch {
            print("Failed to save file: \(error)")
        }
    }
    
    func getImage(for id: String) -> UIImage? {
        let url = url(for: id)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
    
    func containsImage(for id: String) -> Bool {
        let url = url(for: id)
        return fileManager.fileExists(atPath: url.path)
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
    
    // MARK: - Helpers
    
    private func url(for id: String) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDirectory.appendingPathComponent("\(id).\(imageExtension)")
    }
}
