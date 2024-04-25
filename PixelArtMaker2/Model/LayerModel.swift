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
    
    var saveModel:LayerModelForSave {
        let cms = colors.map { list in
            list.map { color in
                return ColorModel(color: color)
            }
        }
        return .init(colorsModels: cms, blendModeRawVlaue: blendMode.rawValue, id: id)
    }
    
}

struct LayerModelForSave : Codable, Hashable {
    public static func == (lhs: LayerModelForSave, rhs: LayerModelForSave) -> Bool {
        return lhs.id == rhs.id && lhs.colorsModels == rhs.colorsModels && lhs.blendModeRawVlaue == rhs.blendModeRawVlaue
    }
        
    let colorsModels:[[ColorModel]]
    let blendModeRawVlaue:Int32
    let id:String
    
    var layerModel:LayerModel {
        let colors = colorsModels.map { list in
            list.map { colormodel in
                return colormodel.getColor(colorSpace: .sRGB)
            }
        }
        return .init(colors: colors, id: id, blendMode: CGBlendMode(rawValue: blendModeRawVlaue)!)
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
