//
//  Color+Extensions.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/02/21.
//

import Foundation
import SwiftUI
extension Color {
    static let k_background = Color(uiColor: UIColor(named: "background")!)
    static let k_pointer = Color(uiColor: UIColor(named: "pointer")!)
    static let k_pointer2 = Color(uiColor: UIColor(named: "pointer2")!)
    static let k_tagBackground = Color(uiColor: UIColor(named: "tagBackground")!)
    static let k_tagText = Color(uiColor: UIColor(named: "tagText")!)
    static let K_boldText = Color(uiColor: UIColor(named: "boldText")!)
    static let k_normalText = Color(uiColor: UIColor(named: "normalText")!)
    static let k_weakText = Color(uiColor: UIColor(named:"weakText")!)
    static let k_dim = Color(uiColor: UIColor(named: "dim")!)
    var uiColor:UIColor {
        UIColor(red: ciColor.red, green: ciColor.green, blue: ciColor.blue, alpha: ciColor.alpha)
    }
    
    /** 컬러의 차이값을 구한다.*/
    func compare(color:Color)->Int {
        let s = ciColor
        let t = color.ciColor
        let r = abs(s.red - t.red)
        let g = abs(s.green - t.green)
        let b = abs(s.blue - t.blue)
        let o = abs(s.alpha - t.alpha)
        return Int((r + g + b + o) * 1020)
    }
    
    static var randomColor:Color {
        return .init(rgb: (Int.random(in: 0...255), Int.random(in: 0...255), Int.random(in: 0...255)))
    }
    
    static var lastSelectColors:[Color]? {
        let idx = UserDefaults.standard.lastColorPresetIndexPath
        let key = colorPresetNames[idx.section]
        if let colors = presetColors[key] {
            if idx.row < colors.count {
                return colors[idx.row]
            }
        }
        return nil
    }
    
    static var colorPresetNames:[String] {
        let keys = Color.presetColors.map { result in
            return result.key
        }
        return keys.sorted()
    }
    
    static func getColorsFromPreset(indexPath:IndexPath)->[Color]? {
        if indexPath.section < colorPresetNames.count {
            let key = colorPresetNames[indexPath.section]
            if let list = presetColors[key] {
                if indexPath.row < list.count {
                    return list[indexPath.row]
                }
            }
        }        
        return nil
    }
    
    static let presetColors:[String:[[Color]]] =
    [
        "default" :
            [
                [.red,.orange,.yellow,.green,.blue,.white,.black],
                [
                    .init(red: 1.0 / 7, green: 0, blue: 0),
                    .init(red: 1.0 / 7 * 2, green: 0, blue: 0),
                    .init(red: 1.0 / 7 * 3, green: 0, blue: 0),
                    .init(red: 1.0 / 7 * 4, green: 0, blue: 0),
                    .init(red: 1.0 / 7 * 5, green: 0, blue: 0),
                    .init(red: 1.0 / 7 * 6, green: 0, blue: 0),
                    .init(red: 1.0 , green: 0, blue: 0)
                ],
                [
                    .init(red: 0, green: 1.0 / 7, blue: 0),
                    .init(red: 0, green: 1.0 / 7 * 2, blue: 0),
                    .init(red: 0, green: 1.0 / 7 * 3, blue: 0),
                    .init(red: 0, green: 1.0 / 7 * 4, blue: 0),
                    .init(red: 0, green: 1.0 / 7 * 5, blue: 0),
                    .init(red: 0, green: 1.0 / 7 * 6, blue: 0),
                    .init(red: 0, green: 1.0, blue: 0)
                ],
                [
                    .init(red: 0, green: 0, blue: 1.0 / 7),
                    .init(red: 0, green: 0, blue: 1.0 / 7 * 2),
                    .init(red: 0, green: 0, blue: 1.0 / 7 * 3),
                    .init(red: 0, green: 0, blue: 1.0 / 7 * 4),
                    .init(red: 0, green: 0, blue: 1.0 / 7 * 5),
                    .init(red: 0, green: 0, blue: 1.0 / 7 * 6),
                    .init(red: 0, green: 0, blue: 1.0)
                ],
                [
                    .init(red: 1.0 / 7, green: 1.0 / 7, blue: 0),
                    .init(red: 1.0 / 7 * 2, green: 1.0 / 7 * 2, blue: 0),
                    .init(red: 1.0 / 7 * 3, green: 1.0 / 7 * 3, blue: 0),
                    .init(red: 1.0 / 7 * 4, green: 1.0 / 7 * 4, blue: 0),
                    .init(red: 1.0 / 7 * 5, green: 1.0 / 7 * 5, blue: 0),
                    .init(red: 1.0 / 7 * 6, green: 1.0 / 7 * 6, blue: 0),
                    .init(red: 1.0 , green: 1.0, blue: 0)
                ],
                [
                    .init(red: 1.0 / 7, green: 0, blue: 1.0 / 7),
                    .init(red: 1.0 / 7 * 2, green: 0, blue: 1.0 / 7 * 2),
                    .init(red: 1.0 / 7 * 3, green: 0, blue: 1.0 / 7 * 3),
                    .init(red: 1.0 / 7 * 4, green: 0, blue: 1.0 / 7 * 4),
                    .init(red: 1.0 / 7 * 5, green: 0, blue: 1.0 / 7 * 5),
                    .init(red: 1.0 / 7 * 6, green: 0, blue: 1.0 / 7 * 6),
                    .init(red: 1.0 , green: 0.0, blue: 1.0 )
                ],
                [
                    .init(red: 0, green: 1.0 / 7, blue: 1.0 / 7),
                    .init(red: 0, green: 1.0 / 7 * 2, blue: 1.0 / 7 * 2),
                    .init(red: 0, green: 1.0 / 7 * 3, blue: 1.0 / 7 * 3),
                    .init(red: 0, green: 1.0 / 7 * 4, blue: 1.0 / 7 * 4),
                    .init(red: 0, green: 1.0 / 7 * 5, blue: 1.0 / 7 * 5),
                    .init(red: 0, green: 1.0 / 7 * 6, blue: 1.0 / 7 * 6),
                    .init(red: 0 , green: 1.0 , blue: 1.0 )
                ],
            ],
        "gray scale":
            [
                [.init(white: 0 ),
                 .init(white: 1.0 / 13 ),
                 .init(white: 1.0 / 13 * 2),
                 .init(white: 1.0 / 13 * 3),
                 .init(white: 1.0 / 13 * 4),
                 .init(white: 1.0 / 13 * 5),
                 .init(white: 1.0 / 13 * 6)]
                ,
                [.init(white: 1.0 / 13 * 7 ),
                 .init(white: 1.0 / 13 * 8),
                 .init(white: 1.0 / 13 * 9),
                 .init(white: 1.0 / 13 * 10),
                 .init(white: 1.0 / 13 * 11),
                 .init(white: 1.0 / 13 * 12),
                 .init(white: 1.0)
                ],
                [
                    .init(rgb:(0,0,255/13/2)),
                    .init(rgb:(255/15,255/15,255/13)),
                    .init(rgb:(255/15*2,255/15*2,255/13*2)),
                    .init(rgb:(255/15*3,255/15*3,255/13*3)),
                    .init(rgb:(255/15*4,255/15*4,255/13*4)),
                    .init(rgb:(255/15*5,255/15*5,255/13*5)),
                    .init(rgb:(255/15*6,255/15*6,255/13*6)),
                ],
                [
                    .init(rgb:(255/15*7,255/15*7,255/13*7)),
                    .init(rgb:(255/15*8,255/15*8,255/13*8)),
                    .init(rgb:(255/15*9,255/15*9,255/13*9)),
                    .init(rgb:(255/15*10,255/15*10,255/13*10)),
                    .init(rgb:(255/15*11,255/15*11,255/13*11)),
                    .init(rgb:(255/15*12,255/15*12,255/13*12)),
                    .init(rgb:(255/15*13,255/15*13,255)),
                ],
                
                [
                    .init(rgb:(0,255/13/2,0)),
                    .init(rgb:(255/15,255/13,255/15)),
                    .init(rgb:(255/15*2,255/13*2,255/15*2)),
                    .init(rgb:(255/15*3,255/13*3,255/15*3)),
                    .init(rgb:(255/15*4,255/13*4,255/15*4)),
                    .init(rgb:(255/15*5,255/13*5,255/15*5)),
                    .init(rgb:(255/15*6,255/13*6,255/15*6)),
                ],
                [
                    .init(rgb:(255/15*7,255/13*7,255/15*7)),
                    .init(rgb:(255/15*8,255/13*8,255/15*8)),
                    .init(rgb:(255/15*9,255/13*9,255/15*9)),
                    .init(rgb:(255/15*10,255/13*10,255/15*10)),
                    .init(rgb:(255/15*11,255/13*11,255/15*11)),
                    .init(rgb:(255/15*12,255/13*12,255/15*12)),
                    .init(rgb:(255/15*13,255,255/15*13)),
                ],
                
                [
                    .init(rgb:(255/13/2,0,0)),
                    .init(rgb:(255/13,255/15,255/15)),
                    .init(rgb:(255/13*2,255/15*2,255/15*2)),
                    .init(rgb:(255/13*3,255/15*3,255/15*3)),
                    .init(rgb:(255/13*4,255/15*4,255/15*4)),
                    .init(rgb:(255/13*5,255/15*5,255/15*5)),
                    .init(rgb:(255/13*6,255/15*6,255/15*6)),
                ],
                [
                    .init(rgb:(255/13*7,255/15*7,255/15*7)),
                    .init(rgb:(255/13*8,255/15*8,255/15*8)),
                    .init(rgb:(255/13*9,255/15*9,255/15*9)),
                    .init(rgb:(255/13*10,255/15*10,255/15*10)),
                    .init(rgb:(255/13*11,255/15*11,255/15*11)),
                    .init(rgb:(255/13*12,255/15*12,255/15*12)),
                    .init(rgb:(255,255/15*13,255/15*13)),
                ],


            ],
        "pantone":
            [
                [
                    .init(rgb:(244,237,124)),
                    .init(rgb:(244,237,71)),
                    .init(rgb:(249,232,20)),
                    .init(rgb:(198,173,15)),
                    .init(rgb:(173,155,12)),
                    .init(rgb:(130,117,15)),
                    .init(rgb:(247,232,89)),
                ],
                [
                    .init(rgb:(249,229,38)),
                    .init(rgb:(249,221,22)),
                    .init(rgb:(249,214,22)),
                    .init(rgb:(216,181,17)),
                    .init(rgb:(170,147,10)),
                    .init(rgb:(153,132,10)),
                    .init(rgb:(249,229,91)),
                ],
                
                [
                    .init(rgb:(249,226,76)),
                    .init(rgb:(249,224,76)),
                    .init(rgb:(252,209,22)),
                    .init(rgb:(198,160,12)),
                    .init(rgb:(170,142,10)),
                    .init(rgb:(137,119,25)),
                    .init(rgb:(249,226,127)),
                ],
                
                [
                    .init(rgb:(249,224,112)),
                    .init(rgb:(252,216,86)),
                    .init(rgb:(255,198,30)),
                    .init(rgb:(224,170,15)),
                    .init(rgb:(181,140,10)),
                    .init(rgb:(163,130,5)),
                    .init(rgb:(244,226,135)),
                ],
                
                [
                    .init(rgb:(244,219,96)),
                    .init(rgb:(242,209,61)),
                    .init(rgb:(234,175,15)),
                    .init(rgb:(198,147,10)),
                    .init(rgb:(158,124,10)),
                    .init(rgb:(112,91,10)),
                    .init(rgb:(255,216,127)),
                ],
                
                [
                    .init(rgb:(252,201,99)),
                    .init(rgb:(252,191,73)),
                    .init(rgb:(252,163,17)),
                    .init(rgb:(216,140,2)),
                    .init(rgb:(175,117,5)),
                    .init(rgb:(122,91,17)),
                    .init(rgb:(242,206,104)),
                ],
                
                [
                    .init(rgb:(242,191,73)),
                    .init(rgb:(239,178,45)),
                    .init(rgb:(226,140,5)),
                    .init(rgb:(198,127,7)),
                    .init(rgb:(158,107,5)),
                    .init(rgb:(114,94,38)),
                    .init(rgb:(255,214,155)),
                ],
                
                [
                    .init(rgb:(252,204,147)),
                    .init(rgb:(252,173,86)),
                    .init(rgb:(247,127,0)),
                    .init(rgb:(221,117,0)),
                    .init(rgb:(188,109,10)),
                    .init(rgb:(153,89,5)),
                    .init(rgb:(244,219,170)),
                ],
                
                [
                    .init(rgb:(242,198,140)),
                    .init(rgb:(237,160,79)),
                    .init(rgb:(232,117,17)),
                    .init(rgb:(198,96,5)),
                    .init(rgb:(158,84,10)),
                    .init(rgb:(99,58,17)),
                    .init(rgb:(249,198,170)),
                ],
                
                [
                    .init(rgb:(252,158,112)),
                    .init(rgb:(252,127,63)),
                    .init(rgb:(249,99,2)),
                    .init(rgb:(221,89,0)),
                    .init(rgb:(188,79,7)),
                    .init(rgb:(109,48,17)),
                    .init(rgb:(249,186,170)),
                ],
                
                [
                    .init(rgb:(249,137,114)),
                    .init(rgb:(249,96,58)),
                    .init(rgb:(247,73,2)),
                    .init(rgb:(209,68,20)),
                    .init(rgb:(147,51,17)),
                    .init(rgb:(109,51,33)),
                    .init(rgb:(249,175,173)),
                ],
                
                [
                    .init(rgb:(249,130,127)),
                    .init(rgb:(249,94,89)),
                    .init(rgb:(226,61,40)),
                    .init(rgb:(193,56,40)),
                    .init(rgb:(124,45,35)),
                    .init(rgb:(249,191,193)),
                    .init(rgb:(252,140,153)),
                ],
                
                [
                    .init(rgb:(252,94,114)),
                    .init(rgb:(232,17,45)),
                    .init(rgb:(206,17,38)),
                    .init(rgb:(175,30,45)),
                    .init(rgb:(124,33,40)),
                    .init(rgb:(255,163,178)),
                    .init(rgb:(252,117,142)),
                ],
                
                [
                    .init(rgb:(244,71,107)),
                    .init(rgb:(229,5,58)),
                    .init(rgb:(219,130,140)),
                    .init(rgb:(153,33,53)),
                    .init(rgb:(244,201,201)),
                    .init(rgb:(239,153,163)),
                    .init(rgb:(119,45,53)),
                ],
                
                [
                    .init(rgb:(216,28,63)),
                    .init(rgb:(196,30,58)),
                    .init(rgb:(163,38,56)),
                    .init(rgb:(140,38,51)),
                    .init(rgb:(242,175,193)),
                    .init(rgb:(237,122,158)),
                    .init(rgb:(229,76,124)),
                ],
                
                [
                    .init(rgb:(211,5,71)),
                    .init(rgb:(186,170,158)),
                    .init(rgb:(142,35,68)),
                    .init(rgb:(117,38,61)),
                    .init(rgb:(255,160,191)),
                    .init(rgb:(255,119,168)),
                    .init(rgb:(249,79,142)),
                ],
                
                [
                    .init(rgb:(234,15,107)),
                    .init(rgb:(204,2,86)),
                    .init(rgb:(165,5,68)),
                    .init(rgb:(124,30,63)),
                    .init(rgb:(244,191,209)),
                    .init(rgb:(237,114,170)),
                    .init(rgb:(226,40,130)),
                ],
                
                [
                    .init(rgb:(170,0,79)),
                    .init(rgb:(147,0,66)),
                    .init(rgb:(112,25,61)),
                    .init(rgb:(249,147,196)),
                    .init(rgb:(244,107,175)),
                    .init(rgb:(237,40,147)),
                    .init(rgb:(214,2,112)),
                ],
                
                [
                    .init(rgb:(173,0,91)),
                    .init(rgb:(140,0,76)),
                    .init(rgb:(109,33,63)),
                    .init(rgb:(255,160,204)),
                    .init(rgb:(252,112,186)),
                    .init(rgb:(244,63,165)),
                    .init(rgb:(206,0,124)),
                ],
                
                [
                    .init(rgb:(170,0,102)),
                    .init(rgb:(142,5,84)),
                    .init(rgb:(249,175,211)),
                    .init(rgb:(244,132,196)),
                    .init(rgb:(237,79,175)),
                    .init(rgb:(224,33,158)),
                    .init(rgb:(196,15,137)),
                ],
                
                [
                    .init(rgb:(173,0,117)),
                    .init(rgb:(124,28,81)),
                    .init(rgb:(242,186,216)),
                    .init(rgb:(237,160,211)),
                    .init(rgb:(232,127,201)),
                    .init(rgb:(204,0,160)),
                    .init(rgb:(183,0,142)),
                ],
                
                [
                    .init(rgb:(163,5,127)),
                    .init(rgb:(127,40,96)),
                    .init(rgb:(237,196,221)),
                    .init(rgb:(226,158,214)),
                    .init(rgb:(211,107,198)),
                    .init(rgb:(175,35,165)),
                    .init(rgb:(160,45,150)),
                ],
                
                [
                    .init(rgb:(119,45,107)),
                    .init(rgb:(229,196,214)),
                    .init(rgb:(211,165,201)),
                    .init(rgb:(155,79,150)),
                    .init(rgb:(114,22,107)),
                    .init(rgb:(104,30,91)),
                    .init(rgb:(94,33,84)),
                ],
                
                [
                    .init(rgb:(84,35,68)),
                    .init(rgb:(224,206,224)),
                    .init(rgb:(198,170,219)),
                    .init(rgb:(150,99,196)),
                    .init(rgb:(109,40,170)),
                    .init(rgb:(89,17,142)),
                    .init(rgb:(79,33,112)),
                ],
                
                [
                    .init(rgb:(68,35,89)),
                    .init(rgb:(186,175,211)),
                    .init(rgb:(158,145,198)),
                    .init(rgb:(137,119,186)),
                    .init(rgb:(56,25,122)),
                    .init(rgb:(43,17,102)),
                    .init(rgb:(38,15,84)),
                ],
                
                [
                    .init(rgb:(43,33,71)),
                    .init(rgb:(181,209,232)),
                    .init(rgb:(153,186,221)),
                    .init(rgb:(102,137,204)),
                    .init(rgb:(0,43,127)),
                    .init(rgb:(0,40,104)),
                    .init(rgb:(0,38,84)),
                ],
                
                [
                    .init(rgb:(155,196,226)),
                    .init(rgb:(117,170,219)),
                    .init(rgb:(58,117,196)),
                    .init(rgb:(0,56,168)),
                    .init(rgb:(0,56,147)),
                    .init(rgb:(0,51,127)),
                    .init(rgb:(0,38,73)),
                ],
                
                [
                    .init(rgb:(196,216,226)),
                    .init(rgb:(168,206,226)),
                    .init(rgb:(117,178,221)),
                    .init(rgb:(0,81,186)),
                    .init(rgb:(0,63,135)),
                    .init(rgb:(0,56,107)),
                    .init(rgb:(0,45,71)),
                ],
                
                [
                    .init(rgb:(130,198,226)),
                    .init(rgb:(81,181,224)),
                    .init(rgb:(0,163,221)),
                    .init(rgb:(0,114,198)),
                    .init(rgb:(0,91,153)),
                    .init(rgb:(0,79,109)),
                    .init(rgb:(0,63,84)),
                ],
                
                [
                    .init(rgb:(165,221,226)),
                    .init(rgb:(112,206,226)),
                    .init(rgb:(0,188,226)),
                    .init(rgb:(0,122,165)),
                    .init(rgb:(0,96,124)),
                    .init(rgb:(0,63,73)),
                    .init(rgb:(114,209,221)),
                ],
                
                [
                    .init(rgb:(40,196,216)),
                    .init(rgb:(0,173,198)),
                    .init(rgb:(0,153,181)),
                    .init(rgb:(0,130,155)),
                    .init(rgb:(0,107,119)),
                    .init(rgb:(0,73,79)),
                    .init(rgb:(201,232,221)),
                ],
                
                [
                    .init(rgb:(147,221,219)),
                    .init(rgb:(76,206,209)),
                    .init(rgb:(0,158,160)),
                    .init(rgb:(0,135,137)),
                    .init(rgb:(0,114,114)),
                    .init(rgb:(0,102,99)),
                    .init(rgb:(170,221,214)),
                ],
                
                [
                    .init(rgb:(86,201,193)),
                    .init(rgb:(0,178,170)),
                    .init(rgb:(0,140,130)),
                    .init(rgb:(0,119,112)),
                    .init(rgb:(0,109,102)),
                    .init(rgb:(0,89,81)),
                    .init(rgb:(186,234,214)),
                ],
                
                [
                    .init(rgb:(160,229,206)),
                    .init(rgb:(94,221,193)),
                    .init(rgb:(0,153,124)),
                    .init(rgb:(0,124,102)),
                    .init(rgb:(0,104,84)),
                    .init(rgb:(155,219,193)),
                    .init(rgb:(122,209,181)),
                ],
                
                [
                    .init(rgb:(0,178,140)),
                    .init(rgb:(0,153,119)),
                    .init(rgb:(0,122,94)),
                    .init(rgb:(0,107,84)),
                    .init(rgb:(0,86,63)),
                    .init(rgb:(181,226,191)),
                    .init(rgb:(150,216,175)),
                ],
                
                [
                    .init(rgb:(112,206,155)),
                    .init(rgb:(0,158,96)),
                    .init(rgb:(0,135,81)),
                    .init(rgb:(0,107,63)),
                    .init(rgb:(35,79,51)),
                    .init(rgb:(181,232,191)),
                    .init(rgb:(153,229,178)),
                ],
                
                [
                    .init(rgb:(132,226,168)),
                    .init(rgb:(0,183,96)),
                    .init(rgb:(0,158,73)),
                    .init(rgb:(0,122,61)),
                    .init(rgb:(33,91,51)),
                    .init(rgb:(170,221,150)),
                    .init(rgb:(160,219,142)),
                ],
                
                [
                    .init(rgb:(96,198,89)),
                    .init(rgb:(30,181,58)),
                    .init(rgb:(51,158,53)),
                    .init(rgb:(61,142,51)),
                    .init(rgb:(58,119,40)),
                    .init(rgb:(211,232,163)),
                    .init(rgb:(196,229,142)),
                ],
                
                [
                    .init(rgb:(170,221,109)),
                    .init(rgb:(91,191,33)),
                    .init(rgb:(86,170,28)),
                    .init(rgb:(86,142,20)),
                    .init(rgb:(86,107,33)),
                    .init(rgb:(216,237,150)),
                    .init(rgb:(206,234,130)),
                ],
                
                [
                    .init(rgb:(186,232,96)),
                    .init(rgb:(140,214,0)),
                    .init(rgb:(127,186,0)),
                    .init(rgb:(112,147,2)),
                    .init(rgb:(86,99,20)),
                    .init(rgb:(224,234,104)),
                    .init(rgb:(214,229,66)),
                ],
                
                [
                    .init(rgb:(204,226,38)),
                    .init(rgb:(186,216,10)),
                    .init(rgb:(163,175,7)),
                    .init(rgb:(147,153,5)),
                    .init(rgb:(112,112,20)),
                    .init(rgb:(232,237,96)),
                    .init(rgb:(224,237,68)),
                ],
                
                [
                    .init(rgb:(214,232,15)),
                    .init(rgb:(206,224,7)),
                    .init(rgb:(186,196,5)),
                    .init(rgb:(158,158,7)),
                    .init(rgb:(132,130,5)),
                    .init(rgb:(242,239,135)),
                    .init(rgb:(234,237,53)),
                ],
                
                [
                    .init(rgb:(229,232,17)),
                    .init(rgb:(224,226,12)),
                    .init(rgb:(193,191,10)),
                    .init(rgb:(175,168,10)),
                    .init(rgb:(153,142,7)),
                    .init(rgb:(209,198,181)),
                    .init(rgb:(193,181,165)),
                ],
                
                [
                    .init(rgb:(175,165,147)),
                    .init(rgb:(153,140,124)),
                    .init(rgb:(130,117,102)),
                    .init(rgb:(107,94,79)),
                    .init(rgb:(206,193,181)),
                    .init(rgb:(168,153,140)),
                    .init(rgb:(153,137,124)),
                ],
                
                [
                    .init(rgb:(124,109,99)),
                    .init(rgb:(102,89,76)),
                    .init(rgb:(61,48,40)),
                    .init(rgb:(198,193,178)),
                    .init(rgb:(181,175,160)),
                    .init(rgb:(163,158,140)),
                    .init(rgb:(142,140,122)),
                ],
                
                [
                    .init(rgb:(119,114,99)),
                    .init(rgb:(96,94,79)),
                    .init(rgb:(40,40,33)),
                    .init(rgb:(209,204,191)),
                    .init(rgb:(191,186,175)),
                    .init(rgb:(175,170,163)),
                    .init(rgb:(150,147,142)),
                ],
                
                [
                    .init(rgb:(130,127,119)),
                    .init(rgb:(96,96,91)),
                    .init(rgb:(43,43,40)),
                    .init(rgb:(221,219,209)),
                    .init(rgb:(209,206,198)),
                    .init(rgb:(173,175,170)),
                    .init(rgb:(145,150,147)),
                ],
                
                [
                    .init(rgb:(102,109,112)),
                    .init(rgb:(68,79,81)),
                    .init(rgb:(48,56,58)),
                    .init(rgb:(224,209,198)),
                    .init(rgb:(211,191,183)),
                    .init(rgb:(188,165,158)),
                    .init(rgb:(140,112,107)),
                ],
                
                [
                    .init(rgb:(89,63,61)),
                    .init(rgb:(73,53,51)),
                    .init(rgb:(63,48,43)),
                    .init(rgb:(209,209,198)),
                    .init(rgb:(186,191,183)),
                    .init(rgb:(163,168,163)),
                    .init(rgb:(137,142,140)),
                ],
                
                [
                    .init(rgb:(86,89,89)),
                    .init(rgb:(73,76,73)),
                    .init(rgb:(63,63,56)),
                    .init(rgb:(84,71,45)),
                    .init(rgb:(84,71,38)),
                    .init(rgb:(96,84,43)),
                    .init(rgb:(173,160,122)),
                ],
                
                [
                    .init(rgb:(196,183,150)),
                    .init(rgb:(214,204,175)),
                    .init(rgb:(226,216,191)),
                    .init(rgb:(102,86,20)),
                    .init(rgb:(153,135,20)),
                    .init(rgb:(181,155,12)),
                    .init(rgb:(221,204,107)),
                ],
                
                [
                    .init(rgb:(226,214,124)),
                    .init(rgb:(234,221,150)),
                    .init(rgb:(237,229,173)),
                    .init(rgb:(91,71,35)),
                    .init(rgb:(117,84,38)),
                    .init(rgb:(135,96,40)),
                    .init(rgb:(193,168,117)),
                ],
                
                [
                    .init(rgb:(209,191,145)),
                    .init(rgb:(221,204,165)),
                    .init(rgb:(226,214,181)),
                    .init(rgb:(96,51,17)),
                    .init(rgb:(155,79,25)),
                    .init(rgb:(188,94,30)),
                    .init(rgb:(234,170,122)),
                ],
                
                [
                    .init(rgb:(244,196,160)),
                    .init(rgb:(244,204,170)),
                    .init(rgb:(247,211,181)),
                    .init(rgb:(89,61,43)),
                    .init(rgb:(99,56,38)),
                    .init(rgb:(122,63,40)),
                    .init(rgb:(175,137,112)),
                ],
                
                [
                    .init(rgb:(211,183,163)),
                    .init(rgb:(224,204,186)),
                    .init(rgb:(229,211,193)),
                    .init(rgb:(107,48,33)),
                    .init(rgb:(155,48,28)),
                    .init(rgb:(216,30,5)),
                    .init(rgb:(237,158,132)),
                ],
                
                [
                    .init(rgb:(239,181,160)),
                    .init(rgb:(242,196,175)),
                    .init(rgb:(242,209,191)),
                    .init(rgb:(91,38,38)),
                    .init(rgb:(117,40,40)),
                    .init(rgb:(145,51,56)),
                    .init(rgb:(242,173,178)),
                ],
                
                [
                    .init(rgb:(244,188,191)),
                    .init(rgb:(247,201,198)),
                    .init(rgb:(81,40,38)),
                    .init(rgb:(109,51,43)),
                    .init(rgb:(122,56,45)),
                    .init(rgb:(206,137,140)),
                    .init(rgb:(234,178,178)),
                ],
                
                [
                    .init(rgb:(242,198,196)),
                    .init(rgb:(244,209,204)),
                    .init(rgb:(81,30,38)),
                    .init(rgb:(102,30,43)),
                    .init(rgb:(122,38,56)),
                    .init(rgb:(216,137,155)),
                    .init(rgb:(232,165,175)),
                ],
                
                [
                    .init(rgb:(242,186,191)),
                    .init(rgb:(244,198,201)),
                    .init(rgb:(96,33,68)),
                    .init(rgb:(132,33,107)),
                    .init(rgb:(158,35,135)),
                    .init(rgb:(216,132,188)),
                    .init(rgb:(232,163,201)),
                ],
                
                [
                    .init(rgb:(242,186,211)),
                    .init(rgb:(244,204,216)),
                    .init(rgb:(81,45,68)),
                    .init(rgb:(99,48,94)),
                    .init(rgb:(112,53,114)),
                    .init(rgb:(181,140,178)),
                    .init(rgb:(198,163,193)),
                ],
                
                [
                    .init(rgb:(211,183,204)),
                    .init(rgb:(226,204,211)),
                    .init(rgb:(81,38,84)),
                    .init(rgb:(104,33,122)),
                    .init(rgb:(122,30,153)),
                    .init(rgb:(175,114,193)),
                    .init(rgb:(206,163,211)),
                ],
                
                [
                    .init(rgb:(214,175,214)),
                    .init(rgb:(229,198,219)),
                    .init(rgb:(53,56,66)),
                    .init(rgb:(53,63,91)),
                    .init(rgb:(58,73,114)),
                    .init(rgb:(155,163,183)),
                    .init(rgb:(173,178,193)),
                ],
                
                [
                    .init(rgb:(196,198,206)),
                    .init(rgb:(214,211,214)),
                    .init(rgb:(0,48,73)),
                    .init(rgb:(0,51,91)),
                    .init(rgb:(0,63,119)),
                    .init(rgb:(102,147,188)),
                    .init(rgb:(147,183,209)),
                ],
                
                [
                    .init(rgb:(183,204,219)),
                    .init(rgb:(196,211,221)),
                    .init(rgb:(12,56,68)),
                    .init(rgb:(0,63,84)),
                    .init(rgb:(0,68,89)),
                    .init(rgb:(94,153,170)),
                    .init(rgb:(135,175,191)),
                ],
                
                [
                    .init(rgb:(163,193,201)),
                    .init(rgb:(196,214,214)),
                    .init(rgb:(35,68,53)),
                    .init(rgb:(25,94,71)),
                    .init(rgb:(7,109,84)),
                    .init(rgb:(122,168,145)),
                    .init(rgb:(163,193,173)),
                ],
                
                [
                    .init(rgb:(183,206,188)),
                    .init(rgb:(198,214,196)),
                    .init(rgb:(43,76,63)),
                    .init(rgb:(38,102,89)),
                    .init(rgb:(30,122,109)),
                    .init(rgb:(127,188,170)),
                    .init(rgb:(5,112,94)),
                ],
                
                [
                    .init(rgb:(188,219,204)),
                    .init(rgb:(209,226,211)),
                    .init(rgb:(38,81,66)),
                    .init(rgb:(0,135,114)),
                    .init(rgb:(127,198,178)),
                    .init(rgb:(170,219,198)),
                    .init(rgb:(188,226,206)),
                ],
                
                [
                    .init(rgb:(204,229,214)),
                    .init(rgb:(73,89,40)),
                    .init(rgb:(84,119,48)),
                    .init(rgb:(96,142,58)),
                    .init(rgb:(181,204,142)),
                    .init(rgb:(198,214,160)),
                    .init(rgb:(201,214,163)),
                ],
                
                [
                    .init(rgb:(216,221,181)),
                    .init(rgb:(96,94,17)),
                    .init(rgb:(135,137,5)),
                    .init(rgb:(170,186,10)),
                    .init(rgb:(206,214,73)),
                    .init(rgb:(219,224,107)),
                    .init(rgb:(226,229,132)),
                ],
                
                [
                    .init(rgb:(232,232,155)),
                    .init(rgb:(244,237,175)),
                    .init(rgb:(242,237,158)),
                    .init(rgb:(242,234,135)),
                    .init(rgb:(237,232,91)),
                    .init(rgb:(232,221,33)),
                    .init(rgb:(221,206,17)),
                ],
                
                [
                    .init(rgb:(211,191,17)),
                    .init(rgb:(242,234,188)),
                    .init(rgb:(239,232,173)),
                    .init(rgb:(234,229,150)),
                    .init(rgb:(226,219,114)),
                    .init(rgb:(214,206,73)),
                    .init(rgb:(196,186,0)),
                ],
                
                [
                    .init(rgb:(175,160,12)),
                    .init(rgb:(234,226,183)),
                    .init(rgb:(226,219,170)),
                    .init(rgb:(221,214,155)),
                    .init(rgb:(204,196,124)),
                    .init(rgb:(181,170,89)),
                    .init(rgb:(150,140,40)),
                ],
                
                [
                    .init(rgb:(132,119,17)),
                    .init(rgb:(216,221,206)),
                    .init(rgb:(193,209,191)),
                    .init(rgb:(165,191,170)),
                    .init(rgb:(127,160,140)),
                    .init(rgb:(91,135,114)),
                    .init(rgb:(33,84,63)),
                ],
                
                [
                    .init(rgb:(12,48,38)),
                    .init(rgb:(204,226,221)),
                    .init(rgb:(178,216,216)),
                    .init(rgb:(140,204,211)),
                    .init(rgb:(84,183,198)),
                    .init(rgb:(0,160,186)),
                    .init(rgb:(0,127,153)),
                ],
                
                [
                    .init(rgb:(0,102,127)),
                    .init(rgb:(186,224,224)),
                    .init(rgb:(153,214,221)),
                    .init(rgb:(107,201,219)),
                    .init(rgb:(0,181,214)),
                    .init(rgb:(0,160,196)),
                    .init(rgb:(0,140,178)),
                ],
                
                [
                    .init(rgb:(0,122,165)),
                    .init(rgb:(209,216,216)),
                    .init(rgb:(198,209,214)),
                    .init(rgb:(155,175,196)),
                    .init(rgb:(119,150,178)),
                    .init(rgb:(94,130,163)),
                    .init(rgb:(38,84,124)),
                ],
                
                [
                    .init(rgb:(0,48,94)),
                    .init(rgb:(214,214,216)),
                    .init(rgb:(191,198,209)),
                    .init(rgb:(155,170,191)),
                    .init(rgb:(109,135,168)),
                    .init(rgb:(51,86,135)),
                    .init(rgb:(15,43,91)),
                ],
                
                [
                    .init(rgb:(12,28,71)),
                    .init(rgb:(214,219,224)),
                    .init(rgb:(193,201,221)),
                    .init(rgb:(165,175,214)),
                    .init(rgb:(127,140,191)),
                    .init(rgb:(89,96,168)),
                    .init(rgb:(45,51,142)),
                ],
                
                [
                    .init(rgb:(12,25,117)),
                    .init(rgb:(226,211,214)),
                    .init(rgb:(216,204,209)),
                    .init(rgb:(198,181,196)),
                    .init(rgb:(168,147,173)),
                    .init(rgb:(127,102,137)),
                    .init(rgb:(102,73,117)),
                ],
                
                [
                    .init(rgb:(71,43,89)),
                    .init(rgb:(242,214,216)),
                    .init(rgb:(239,198,211)),
                    .init(rgb:(234,170,196)),
                    .init(rgb:(224,140,178)),
                    .init(rgb:(211,107,158)),
                    .init(rgb:(188,56,119)),
                ],
                
                [
                    .init(rgb:(160,0,84)),
                    .init(rgb:(237,214,214)),
                    .init(rgb:(234,204,206)),
                    .init(rgb:(229,191,198)),
                    .init(rgb:(211,158,175)),
                    .init(rgb:(183,114,142)),
                    .init(rgb:(160,81,117)),
                ],
                
                [
                    .init(rgb:(127,40,79)),
                    .init(rgb:(239,204,206)),
                    .init(rgb:(234,191,196)),
                    .init(rgb:(224,170,186)),
                    .init(rgb:(201,137,158)),
                    .init(rgb:(178,102,132)),
                    .init(rgb:(147,66,102)),
                ],
                
                [
                    .init(rgb:(112,35,66)),
                    .init(rgb:(239,209,201)),
                    .init(rgb:(232,191,186)),
                    .init(rgb:(219,168,165)),
                    .init(rgb:(201,140,140)),
                    .init(rgb:(178,107,112)),
                    .init(rgb:(142,71,73)),
                ],
                
                [
                    .init(rgb:(127,56,58)),
                    .init(rgb:(247,209,204)),
                    .init(rgb:(247,191,191)),
                    .init(rgb:(242,165,170)),
                    .init(rgb:(232,135,142)),
                    .init(rgb:(214,96,109)),
                    .init(rgb:(183,56,68)),
                ],
                
                [
                    .init(rgb:(158,40,40)),
                    .init(rgb:(249,221,214)),
                    .init(rgb:(252,201,198)),
                    .init(rgb:(252,173,175)),
                    .init(rgb:(249,142,153)),
                    .init(rgb:(242,104,119)),
                    .init(rgb:(224,66,81)),
                ],
                
                [
                    .init(rgb:(209,45,51)),
                    .init(rgb:(255,211,170)),
                    .init(rgb:(249,201,163)),
                    .init(rgb:(249,186,130)),
                    .init(rgb:(252,158,73)),
                    .init(rgb:(242,132,17)),
                    .init(rgb:(211,109,0)),
                ],
                
                [
                    .init(rgb:(191,91,0)),
                    .init(rgb:(244,209,175)),
                    .init(rgb:(239,196,158)),
                    .init(rgb:(232,178,130)),
                    .init(rgb:(209,142,84)),
                    .init(rgb:(186,117,48)),
                    .init(rgb:(142,73,5)),
                ],
                
                [
                    .init(rgb:(117,56,2)),
                    .init(rgb:(237,211,181)),
                    .init(rgb:(226,191,155)),
                    .init(rgb:(211,168,124)),
                    .init(rgb:(193,142,96)),
                    .init(rgb:(170,117,63)),
                    .init(rgb:(114,63,10)),
                ],
                
                [
                    .init(rgb:(96,51,10)),
                    .init(rgb:(0,170,204)),
                    .init(rgb:(96,221,73)),
                    .init(rgb:(255,237,56)),
                    .init(rgb:(255,147,56)),
                    .init(rgb:(249,89,81)),
                    .init(rgb:(255,0,147)),
                ],
                
                [
                    .init(rgb:(214,0,158)),
                    .init(rgb:(0,181,155)),
                    .init(rgb:(221,224,15)),
                    .init(rgb:(255,204,30)),
                    .init(rgb:(255,114,71)),
                    .init(rgb:(252,35,102)),
                    .init(rgb:(229,0,153)),
                ],
                
                [
                    .init(rgb:(140,96,193)),
                    .init(rgb:(247,232,170)),
                    .init(rgb:(249,224,140)),
                    .init(rgb:(255,204,73)),
                    .init(rgb:(252,181,20)),
                    .init(rgb:(191,145,12)),
                    .init(rgb:(163,127,20)),
                ],
                
                [
                    .init(rgb:(124,99,22)),
                    .init(rgb:(255,214,145)),
                    .init(rgb:(252,206,135)),
                    .init(rgb:(252,186,94)),
                    .init(rgb:(249,155,12)),
                    .init(rgb:(204,122,2)),
                    .init(rgb:(153,96,7)),
                ],
                
                [
                    .init(rgb:(107,71,20)),
                    .init(rgb:(255,183,119)),
                    .init(rgb:(255,153,63)),
                    .init(rgb:(244,124,0)),
                    .init(rgb:(181,84,0)),
                    .init(rgb:(140,68,0)),
                    .init(rgb:(76,40,15)),
                ],
                
                [
                    .init(rgb:(249,191,158)),
                    .init(rgb:(252,165,119)),
                    .init(rgb:(252,135,68)),
                    .init(rgb:(249,107,7)),
                    .init(rgb:(209,91,5)),
                    .init(rgb:(160,79,17)),
                    .init(rgb:(132,63,15)),
                ],
                
                [
                    .init(rgb:(249,165,140)),
                    .init(rgb:(249,142,109)),
                    .init(rgb:(249,114,66)),
                    .init(rgb:(249,86,2)),
                    .init(rgb:(221,79,5)),
                    .init(rgb:(165,63,15)),
                    .init(rgb:(132,53,17)),
                ],
                
                [
                    .init(rgb:(249,158,163)),
                    .init(rgb:(249,178,183)),
                    .init(rgb:(249,132,142)),
                    .init(rgb:(252,102,117)),
                    .init(rgb:(252,79,89)),
                    .init(rgb:(244,63,79)),
                    .init(rgb:(239,43,45)),
                ],
                
                [
                    .init(rgb:(214,40,40)),
                    .init(rgb:(204,45,48)),
                    .init(rgb:(175,38,38)),
                    .init(rgb:(160,48,51)),
                    .init(rgb:(124,33,30)),
                    .init(rgb:(91,45,40)),
                    .init(rgb:(252,191,201)),
                ],
                
                [
                    .init(rgb:(252,155,178)),
                    .init(rgb:(244,84,124)),
                    .init(rgb:(224,7,71)),
                    .init(rgb:(193,5,56)),
                    .init(rgb:(168,12,53)),
                    .init(rgb:(147,22,56)),
                    .init(rgb:(247,196,216)),
                ],
                
                [
                    .init(rgb:(234,107,191)),
                    .init(rgb:(219,40,165)),
                    .init(rgb:(196,0,140)),
                    .init(rgb:(168,0,122)),
                    .init(rgb:(155,0,112)),
                    .init(rgb:(135,0,91)),
                    .init(rgb:(216,168,216)),
                ],
                
                [
                    .init(rgb:(209,160,204)),
                    .init(rgb:(191,147,204)),
                    .init(rgb:(198,135,209)),
                    .init(rgb:(186,124,188)),
                    .init(rgb:(170,114,191)),
                    .init(rgb:(170,71,186)),
                    .init(rgb:(158,79,165)),
                ],
                
                [
                    .init(rgb:(142,71,173)),
                    .init(rgb:(147,15,165)),
                    .init(rgb:(135,43,147)),
                    .init(rgb:(102,0,140)),
                    .init(rgb:(130,12,142)),
                    .init(rgb:(112,20,122)),
                    .init(rgb:(91,2,122)),
                ],
                
                [
                    .init(rgb:(112,30,114)),
                    .init(rgb:(102,17,109)),
                    .init(rgb:(86,12,112)),
                    .init(rgb:(96,45,89)),
                    .init(rgb:(91,25,94)),
                    .init(rgb:(76,20,94)),
                    .init(rgb:(201,173,216)),
                ],
                
                [
                    .init(rgb:(181,145,209)),
                    .init(rgb:(155,109,198)),
                    .init(rgb:(137,79,191)),
                    .init(rgb:(86,0,140)),
                    .init(rgb:(68,35,94)),
                    .init(rgb:(173,158,211)),
                    .init(rgb:(209,206,221)),
                ],
                
                [
                    .init(rgb:(191,209,229)),
                    .init(rgb:(175,188,219)),
                    .init(rgb:(147,122,204)),
                    .init(rgb:(165,160,214)),
                    .init(rgb:(165,186,224)),
                    .init(rgb:(91,119,204)),
                    .init(rgb:(114,81,188)),
                ],
                
                [
                    .init(rgb:(102,86,188)),
                    .init(rgb:(94,104,196)),
                    .init(rgb:(48,68,181)),
                    .init(rgb:(79,0,147)),
                    .init(rgb:(73,48,173)),
                    .init(rgb:(45,0,142)),
                    .init(rgb:(63,0,119)),
                ],
                
                [
                    .init(rgb:(63,40,147)),
                    .init(rgb:(28,20,107)),
                    .init(rgb:(30,28,119)),
                    .init(rgb:(53,0,109)),
                    .init(rgb:(51,40,117)),
                    .init(rgb:(20,22,84)),
                    .init(rgb:(25,33,104)),
                ],
                
                [
                    .init(rgb:(43,12,86)),
                    .init(rgb:(43,38,91)),
                    .init(rgb:(20,33,61)),
                    .init(rgb:(17,33,81)),
                    .init(rgb:(147,198,224)),
                    .init(rgb:(96,175,221)),
                    .init(rgb:(0,142,214)),
                ],
                
                [
                    .init(rgb:(0,91,191)),
                    .init(rgb:(0,84,160)),
                    .init(rgb:(0,61,107)),
                    .init(rgb:(0,51,76)),
                    .init(rgb:(186,224,226)),
                    .init(rgb:(81,191,226)),
                    .init(rgb:(0,165,219)),
                ],
                
                [
                    .init(rgb:(0,132,201)),
                    .init(rgb:(0,112,158)),
                    .init(rgb:(0,84,107)),
                    .init(rgb:(0,68,84)),
                    .init(rgb:(127,214,219)),
                    .init(rgb:(45,198,214)),
                    .init(rgb:(0,183,198)),
                ],
                
                [
                    .init(rgb:(0,155,170)),
                    .init(rgb:(0,132,142)),
                    .init(rgb:(0,109,117)),
                    .init(rgb:(0,86,91)),
                    .init(rgb:(135,221,209)),
                    .init(rgb:(140,224,209)),
                    .init(rgb:(122,211,193)),
                ],
                
                [
                    .init(rgb:(86,214,201)),
                    .init(rgb:(71,214,193)),
                    .init(rgb:(53,196,175)),
                    .init(rgb:(0,193,181)),
                    .init(rgb:(0,198,178)),
                    .init(rgb:(0,175,153)),
                    .init(rgb:(0,170,158)),
                ],
                
                [
                    .init(rgb:(0,178,160)),
                    .init(rgb:(0,155,132)),
                    .init(rgb:(0,140,130)),
                    .init(rgb:(0,153,135)),
                    .init(rgb:(0,130,112)),
                    .init(rgb:(0,96,86)),
                    .init(rgb:(0,130,114)),
                ],
                
                [
                    .init(rgb:(0,107,91)),
                    .init(rgb:(0,73,63)),
                    .init(rgb:(0,79,66)),
                    .init(rgb:(0,68,56)),
                    .init(rgb:(142,226,188)),
                    .init(rgb:(84,216,168)),
                    .init(rgb:(0,201,147)),
                ],
                
                [
                    .init(rgb:(0,178,122)),
                    .init(rgb:(0,124,89)),
                    .init(rgb:(0,104,71)),
                    .init(rgb:(2,73,48)),
                    .init(rgb:(242,237,109)),
                    .init(rgb:(239,234,7)),
                    .init(rgb:(237,226,17)),
                ],
                
                [
                    .init(rgb:(232,221,17)),
                    .init(rgb:(181,168,12)),
                    .init(rgb:(153,140,10)),
                    .init(rgb:(109,96,2)),
                    .init(rgb:(96,76,17)),
                    .init(rgb:(135,117,48)),
                    .init(rgb:(160,145,81)),
                ],
                
                [
                    .init(rgb:(188,173,117)),
                    .init(rgb:(204,191,142)),
                    .init(rgb:(219,206,165)),
                    .init(rgb:(229,219,186)),
                    .init(rgb:(71,35,17)),
                    .init(rgb:(140,89,51)),
                    .init(rgb:(178,130,96)),
                ],
                
                [
                    .init(rgb:(196,153,119)),
                    .init(rgb:(216,181,150)),
                    .init(rgb:(229,198,170)),
                    .init(rgb:(237,211,188)),
                    .init(rgb:(81,38,28)),
                    .init(rgb:(124,81,61)),
                    .init(rgb:(153,112,91)),
                ],
                
                [
                    .init(rgb:(181,145,124)),
                    .init(rgb:(204,175,155)),
                    .init(rgb:(216,191,170)),
                    .init(rgb:(226,204,186)),
                    .init(rgb:(68,30,28)),
                    .init(rgb:(132,73,73)),
                    .init(rgb:(165,107,109)),
                ],
                
                [
                    .init(rgb:(188,135,135)),
                    .init(rgb:(216,173,168)),
                    .init(rgb:(226,188,183)),
                    .init(rgb:(237,206,198)),
                    .init(rgb:(79,33,58)),
                    .init(rgb:(117,71,96)),
                    .init(rgb:(147,107,127)),
                ],
                
                [
                    .init(rgb:(173,135,153)),
                    .init(rgb:(204,175,183)),
                    .init(rgb:(224,201,204)),
                    .init(rgb:(232,214,209)),
                    .init(rgb:(71,40,53)),
                    .init(rgb:(89,51,68)),
                    .init(rgb:(142,104,119)),
                ],
                
                [
                    .init(rgb:(181,147,155)),
                    .init(rgb:(204,173,175)),
                    .init(rgb:(221,198,196)),
                    .init(rgb:(229,211,204)),
                    .init(rgb:(53,38,79)),
                    .init(rgb:(73,61,99)),
                    .init(rgb:(96,86,119)),
                ],
                
                [
                    .init(rgb:(140,130,153)),
                    .init(rgb:(178,168,181)),
                    .init(rgb:(204,193,198)),
                    .init(rgb:(219,211,211)),
                    .init(rgb:(2,40,58)),
                    .init(rgb:(63,96,117)),
                    .init(rgb:(96,124,140)),
                ],
                
                [
                    .init(rgb:(132,153,165)),
                    .init(rgb:(175,188,191)),
                    .init(rgb:(196,204,204)),
                    .init(rgb:(214,216,211)),
                    .init(rgb:(0,53,58)),
                    .init(rgb:(25,56,51)),
                    .init(rgb:(38,104,109)),
                ],
                
                [
                    .init(rgb:(58,86,79)),
                    .init(rgb:(96,145,145)),
                    .init(rgb:(102,124,114)),
                    .init(rgb:(140,175,173)),
                    .init(rgb:(145,163,153)),
                    .init(rgb:(170,196,191)),
                    .init(rgb:(175,186,178)),
                ],
                
                [
                    .init(rgb:(206,216,209)),
                    .init(rgb:(201,206,196)),
                    .init(rgb:(214,221,214)),
                    .init(rgb:(206,209,198)),
                    .init(rgb:(33,61,48)),
                    .init(rgb:(79,109,94)),
                    .init(rgb:(119,145,130)),
                ],
                
                [
                    .init(rgb:(150,170,153)),
                    .init(rgb:(175,191,173)),
                    .init(rgb:(196,206,191)),
                    .init(rgb:(216,219,204)),
                    .init(rgb:(35,58,45)),
                    .init(rgb:(84,104,86)),
                    .init(rgb:(114,132,112)),
                ],
                
                [
                    .init(rgb:(158,170,153)),
                    .init(rgb:(188,193,178)),
                    .init(rgb:(198,204,186)),
                    .init(rgb:(214,214,198)),
                    .init(rgb:(63,73,38)),
                    .init(rgb:(66,71,22)),
                    .init(rgb:(94,102,58)),
                ],
                
                [
                    .init(rgb:(107,112,43)),
                    .init(rgb:(119,124,79)),
                    .init(rgb:(140,145,79)),
                    .init(rgb:(155,158,114)),
                    .init(rgb:(170,173,117)),
                    .init(rgb:(181,181,142)),
                    .init(rgb:(198,198,153)),
                ],
                
                [
                    .init(rgb:(198,198,165)),
                    .init(rgb:(211,209,170)),
                    .init(rgb:(216,214,183)),
                    .init(rgb:(224,221,188)),
                    .init(rgb:(73,68,17)),
                    .init(rgb:(117,112,43)),
                    .init(rgb:(158,153,89)),
                ],
                [
                    .init(rgb:(178,170,112)),
                    .init(rgb:(204,198,147)),
                    .init(rgb:(214,206,163)),
                    .init(rgb:(224,219,181)),
                    .clear,
                    .clear,
                    .clear,
                ]
            ]
    ]
    
    
    var ciColor : CIColor {
#if canImport(UIKit)
        typealias NativeColor = UIColor
#elseif canImport(AppKit)
        typealias NativeColor = NSColor
#endif
        
        let cgColor = NativeColor(self).cgColor
        return CIColor(cgColor: cgColor)
    }
    
    var string:String {
        ciColor.stringRepresentation
    }
    
    init(string:String) {
        let c = CIColor(string: string)
        self.init(CGColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha))
    }
    
    init(rgb:Int) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
    
    init(rgb:(Int,Int,Int)) {
        self.init(red: Double(rgb.0) / 255, green: Double(rgb.1) / 255, blue: Double(rgb.2) / 255)
    }
}

