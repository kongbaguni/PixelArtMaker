//
//  Image+Extensions.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/22.
//

import Foundation
import SwiftUI
import UIKit

extension Image {
    public init?(totalColors:[[[Color]]], backgroundColor: Color, size:CGSize) {
        let image = UIImage(totalColors: totalColors, backgroundColor: backgroundColor, size: size)!
        self.init(uiImage: image)
    }    
}
