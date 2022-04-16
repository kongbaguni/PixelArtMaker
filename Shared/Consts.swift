//
//  Consts.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import Foundation
import SwiftUI

struct Consts {
    static var sizes:[CGSize] {
        var result:[CGSize]  = []
        result.append(StageManager.shared.canvasSize / 3)
        result.append(StageManager.shared.canvasSize)
        for i in 1...5 {
            result.append(StageManager.shared.canvasSize * CGFloat(i * 3)) 
            
        }
        return result
    }
    static var sizeTitles:[Text] {
        return sizes.map { size in
            return Text("\(Int(size.width * 3)) * \(Int(size.width * 3))")
        }
    }
    static var previewImageSize:CGSize {
        let s = StageManager.shared.stage?.canvasSize ?? sizes[0]
        return .init(width: s.width * 3, height: s.height * 3)
    }
    
    
    static var canvasSizes:[CGFloat] {
        if InAppPurchaseModel.isSubscribe {
            return [16,24,32,36,48,56,64,72,80,88]
        } else {
            return [16,36,64]
        }
    }
    
    /** 무료모드에서 겔러리 생성 제한 */
    static let free_myGalleryLimit = 50
    /** 무료모드에서 레이어 생성 제한*/
    static let free_layerLimit = 2    
    /** 구독모드에서 레이어 생성 제한*/
    static let plus_layerLimit = 5
}
