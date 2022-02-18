//
//  StageManager.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/18.
//

import Foundation
class StageManager {
    static let shared = StageManager() 
    var stage = StageModel(canvasSize: .init(width: 32, height: 32))
    
}
