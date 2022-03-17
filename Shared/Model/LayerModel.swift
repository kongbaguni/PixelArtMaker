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
        return lhs.id == rhs.id && lhs.colors == rhs.colors
    }

    let colors:[[Color]]
    
    let isOn:Bool
    
    let opacity:CGFloat
    
    var id = UUID().uuidString
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
        self.isOn = true
        self.opacity = 1.0
    }
    
    init(colors:[[Color]], isOn:Bool, opacity:CGFloat, id:String) {
        self.id = id
        self.colors = colors
        self.isOn = isOn
        self.opacity = opacity
    }
    
    var width:CGFloat {
        CGFloat(colors.first?.count ?? 0)
    }
    
    var height:CGFloat {
        CGFloat(colors.count)
    }
}

