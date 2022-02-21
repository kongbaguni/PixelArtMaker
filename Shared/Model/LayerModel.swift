//
//  LayerModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import Foundation
import SwiftUI
struct LayerModel {
    var colors:[[Color]]
    
    init(size:CGSize) {
        var colors:[[Color]] = []
        let w = Int(size.width)
        let h = Int(size.height)
        for _ in 0..<h {
            var list:[Color] = []
            for _ in 0..<w {
                list.append(.clear)
            }
            colors.append(list)
        }
        self.colors = colors
    }
    
    var width:CGFloat {
        CGFloat(colors.first?.count ?? 0)
    }
    
    var height:CGFloat {
        CGFloat(colors.count)
    }
    
    mutating func clear() {
        for i in 0..<colors.count {
            for y in 0..<colors[i].count {
                colors[i][y] = .clear
            }
        }
    }
}

