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
}
    
