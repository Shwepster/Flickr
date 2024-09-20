//
//  PhotoService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

protocol PhotoService: Sendable {
    func loadImage(for photo: PhotoDTO, size: PhotoSize) async -> UIImage?
    func cancelPhotoLoading(for photo: PhotoDTO)
}
