//
//  Consts.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import Foundation
import SwiftUI

struct Consts {
    static let sizes:[CGSize] = [
        .init(width: 64, height: 64),
        .init(width: 160, height: 160),
        .init(width: 320, height: 320),
        .init(width: 480, height: 480),
        .init(width: 800, height: 800),
        .init(width: 960, height: 960),
        .init(width: 1280, height: 1280)
    ]
    static var sizeTitles:[Text] {
        return sizes.map { size in
            return Text("\(Int(size.width * 3)) * \(Int(size.width * 3))")
        }
    }
    static var previewImageSize:CGSize {
        let s = StageManager.shared.stage?.canvasSize ?? sizes[0]
        return .init(width: s.width * 3, height: s.height * 3)
    }
    
    
    static let canvasSizes:[CGFloat] = [
        16,24,32,36,48,56,64,72,80,88
    ]
    
}
