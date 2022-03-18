//
//  Color+Extensions.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/02/21.
//

import Foundation
import SwiftUI
extension Color {
    #if MAC
    static let k_background = Color(nsColor: NSColor(named: "background")!)
    static let k_pointer = Color(nsColor: NSColor(named: "pointer")!)
    #else
    static let k_background = Color(uiColor: UIColor(named: "background")!)
    static let k_pointer = Color(uiColor: UIColor(named: "pointer")!)
    #endif
    
    static let presetColors:[[Color]] = [
        [.red,.orange,.yellow,.green,.blue,.purple,.black],
        [
            .init(rgb: 0xf7e214),
            .init(rgb: 0xf4ed7c),
            .init(rgb: 0xf4ed47),
            .init(rgb: 0xf9e814),
            .init(rgb: 0xfce016),
            .init(rgb: 0xc6ad0f),
            .init(rgb: 0xad9b0c)
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
}
    
