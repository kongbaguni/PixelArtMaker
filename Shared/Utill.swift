//
//  Utill.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/14.
//

import SwiftUI

struct Utill {
    static func makeGridItems(length:Int, screenWidth:CGFloat, padding:CGFloat = 10)->[GridItem] {
        let item = GridItem(.fixed((screenWidth - padding * 2) / CGFloat(length)))
        var result:[GridItem] = []
        for _ in 0..<length {
            result.append(item)
        }
        return result
    }

    static func makeItemSize(length:Int, screenWidth:CGFloat, padding:CGFloat = 10) -> CGSize {
        let width = (screenWidth - padding * 2) / CGFloat(length)
        return .init(width: width, height: width + 10)
    }
}
