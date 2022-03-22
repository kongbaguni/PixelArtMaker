//
//  UIScreen+Extensions.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/22.
//

import Foundation
import SwiftUI

var screenBounds:CGRect {
    let bounds = UIScreen.main.bounds
    print(bounds)
    if bounds.width > 1000 {
        return .init(x: 0, y: 0, width: 650, height: 1000)
    }
    return bounds
}
