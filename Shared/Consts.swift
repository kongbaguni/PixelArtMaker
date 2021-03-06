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
        result.append(StageManager.shared.canvasSize * 2)

        
        for i in 3...5 {
            result.append(StageManager.shared.canvasSize * CGFloat(i))
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
        return s
    }
    
    
    static var canvasSizes:[CGFloat] {
        if InAppPurchaseModel.isSubscribe {
            return (1...16).compactMap { value in
                return CGFloat(value * 8)
            }
        } else {
            return [16,36,64]
        }
    }
    /** 타임라인에서 그림 한번에 가져오는  리미트 */
    static let timelineLimit = 20

    /** 프로필에서 바로 그림 보여주기 리미트 */
    static let profileImageLimit = 12

    /** 좋아요 순서로 소트 할 때 리미트 (페이징 없음)*/
    static let likeSortLimit = 24
    
    /** 프로필에서 바로 댓글 보여주기 리미트 */
    static let profileReplyLimit = 5
    /** 타임라인에서 한번에 읽어오는 댓글 리미트 */
    static let timelineLoadReplyLimit = 20
    /** 무료모드에서 겔러리 생성 제한 */
    static let free_myGalleryLimit = 50
    /** 무료모드에서 레이어 생성 제한*/
    static let free_layerLimit = 2    
    /** 구독모드에서 레이어 생성 제한*/
    static let plus_layerLimit = 7
    
    static let imageUploadPath = "shareImages"
}
