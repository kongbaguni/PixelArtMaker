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
    static let imagePlaceHolder = Image("placeHolder").resizable()
    static let profilePlaceHolder = Image("profilePlaceholder").resizable()
    public init?(totalColors:[[[Color]]], blendModes:[CGBlendMode], backgroundColor: Color, size:CGSize) {
        let image = UIImage(totalColors: totalColors, blendModes: blendModes, backgroundColor: backgroundColor, size: size)!
        self.init(uiImage: image)
    }
    
    public init?(pixelSize:(width:Int,height:Int), backgroundColor:Color, size:CGSize) {
        let image = UIImage(pixelSize: pixelSize, backgroundColor: backgroundColor, size: size)!
        self.init(uiImage: image)
    }
}
