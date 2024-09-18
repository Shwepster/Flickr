//
//  PhotoService.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 19.09.2024.
//

import UIKit

protocol PhotoService {
    func loadImage(for photo: PhotoDTO) async -> UIImage?
    func cancelPhotoLoading(for photo: PhotoDTO)
}
