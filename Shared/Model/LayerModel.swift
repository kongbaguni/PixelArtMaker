//
//  LayerModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import Foundation
import SwiftUI
struct LayerModel : Codable, Hashable {
    public static func == (lhs: LayerModel, rhs: LayerModel) -> Bool {
        return lhs.id == rhs.id && lhs.colors == rhs.colors && lhs.blendModeRawVlaue == rhs.blendModeRawVlaue
    }
    
    let colorsModels:[[ColorModel]]
    let blendModeRawVlaue:Int32
    
    var colors:[[Color]] {
        return colorsModels.map { list in
            list.map { model in
                return model.getColor(colorSpace: .sRGB)
            }
        }
    }
    
    var blendMode:CGBlendMode {
        get {
            CGBlendMode(rawValue: blendModeRawVlaue) ?? .normal
        }
    }
    
    var id = UUID().uuidString

    init(size:CGSize, blendMode:CGBlendMode) {
        self.blendModeRawVlaue = blendMode.rawValue
        var colors:[[ColorModel]] = []
        let w = Int(size.width)
        let h = Int(size.height)
        for _ in 0..<h {
            var list:[ColorModel] = []
            for _ in 0..<w {
                list.append(.clear)
            }
            colors.append(list)
        }
        self.colorsModels = colors
    }
    
    init(colors:[[Color]], id:String, blendMode:CGBlendMode) {
        self.id = id
        self.colorsModels = colors.map { list in
            list.map { color in
                return ColorModel(color: color)
            }
        }
        self.blendModeRawVlaue = blendMode.rawValue
    }
    
    var width:CGFloat {
        CGFloat(colors.first?.count ?? 0)
    }
    
    var height:CGFloat {
        CGFloat(colors.count)
    }
}

struct ColorModel : Codable, Hashable {
    public static func == (lhs:ColorModel, rhs:ColorModel) -> Bool {
        lhs.getColor(colorSpace: .sRGB) == rhs.getColor(colorSpace: .sRGB)
    }
    let r:Double
    let g:Double
    let b:Double
    let a:Double
    
    func getColor(colorSpace:Color.RGBColorSpace)->Color {
        Color(colorSpace, red: r, green: g, blue: b, opacity: a)
    }
    
    static let clear:ColorModel = .init(r: 0, g: 0, b: 0, a: 0)
    
    init(r:Double,g:Double,b:Double,a:Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(color:Color) {
        let ci = color.ciColor
        r = ci.red
        g = ci.green
        b = ci.blue
        a = ci.alpha
    }
}
