//
//  UIImage+Image.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 29.10.2024.
//

import UIKit
import SwiftUI

extension UIImage {
    func asImage() -> Image {
        Image(uiImage: self)
    }
}
