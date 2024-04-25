//
//  SortType.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/03.
//

import Foundation
import SwiftUI
struct Sort {
    enum SortType: CaseIterable {
        /** 최근 등록 순서 */
        case latestOrder
        /** 오래된 등록 순서*/
        case oldnet
        /** 좋아요 많은 순서*/
        case like
    }
    
    static let SortTypeForPublicGallery:[SortType] = [.latestOrder, .like]
    static let SortTypeForMyGellery:[SortType] = [.latestOrder, .oldnet]
    static func getText(type:SortType)->Text {
        switch type {
        case .oldnet:
            return Text("old net")
        case .latestOrder:
            return Text("latest order")
        case .like:
            return Text("like")
        }
    }
}
