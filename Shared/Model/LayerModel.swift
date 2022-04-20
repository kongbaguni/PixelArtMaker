//
//  LayerModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import Foundation
import SwiftUI
struct LayerModel : Hashable {
    public static func == (lhs: LayerModel, rhs: LayerModel) -> Bool {
        return lhs.id == rhs.id && lhs.colors == rhs.colors && lhs.blendMode == rhs.blendMode
    }
    
    let colors:[[Color]]
    let blendMode:CGBlendMode
    
    var id = UUID().uuidString
    init(size:CGSize, blendMode:CGBlendMode) {
        self.blendMode = blendMode
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
    
    init(colors:[[Color]], id:String, blendMode:CGBlendMode) {
        self.id = id
        self.colors = colors
        self.blendMode = blendMode
    }
    
    var width:CGFloat {
        CGFloat(colors.first?.count ?? 0)
    }
    
    var height:CGFloat {
        CGFloat(colors.count)
    }
}

