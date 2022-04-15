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
}
