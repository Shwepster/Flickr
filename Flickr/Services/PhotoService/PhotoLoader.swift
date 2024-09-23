//
//  PhotoLoader.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

protocol PhotoLoader: Sendable {
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage?
}
