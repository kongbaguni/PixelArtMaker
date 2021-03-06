//
//  CGSize+Extensions.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/12.
//

import Foundation
import UIKit

extension CGSize {
    static func / (lhs:CGSize, rhs:CGSize)->CGSize {
        return .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    static func / (lhs:CGSize, rhs:Int)->CGSize {
        return .init(width: lhs.width / CGFloat(rhs), height: lhs.height / CGFloat(rhs))
    }
    
    static func * (lhs:CGSize, rhs:CGFloat)->CGSize {
        return .init(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    
    func isOut(cgPoint:CGPoint)->Bool {
        return cgPoint.x < 0 || cgPoint.y < 0 || cgPoint.x >= width || cgPoint.y >= height
    }

    static func getImageSizeForPreviewImage(padding:CGFloat)->CGSize {
        let size = UIScreen.main.bounds.size
        if size.width > size.height {
            let s = size.height - padding * 2
            return .init(width: s, height:s )
        }
        let s = size.width - padding * 2
        return .init(width: s, height: s)
    }
}
