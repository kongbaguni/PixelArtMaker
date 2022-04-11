//
//  GridItem+Extensions.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/11.
//

import Foundation
import SwiftUI

extension GridItem {
    static func makeGridItems(length:Int,width:CGFloat)->[GridItem] {
        var result:[GridItem] = []
        let width = (width / CGFloat(length)) 
        for _ in 0..<length {
            result.append(.init(.fixed(width)))
        }
        return result
    }
}
