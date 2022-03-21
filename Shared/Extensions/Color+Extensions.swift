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
    static let k_pointer2 = Color(nsColor: NSColor(named: "pointer2")!)
    
#else
    static let k_background = Color(uiColor: UIColor(named: "background")!)
    static let k_pointer = Color(uiColor: UIColor(named: "pointer")!)
    static let k_pointer2 = Color(uiColor: UIColor(named: "pointer2")!)
#endif
    
    static let presetColors:[String:[[Color]]] =
    [
        "default" :
            [
                [.red,.orange,.yellow,.green,.blue,.purple,.black],
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
                [.init(white: 1.0 / 14 ),
                 .init(white: 1.0 / 14 * 2),
                 .init(white: 1.0 / 14 * 3),
                 .init(white: 1.0 / 14 * 4),
                 .init(white: 1.0 / 14 * 5),
                 .init(white: 1.0 / 14 * 6),
                 .init(white: 1.0 / 14 * 7)]
                ,
                [.init(white: 1.0 / 14 * 8 ),
                 .init(white: 1.0 / 14 * 9),
                 .init(white: 1.0 / 14 * 10),
                 .init(white: 1.0 / 14 * 11),
                 .init(white: 1.0 / 14 * 12),
                 .init(white: 1.0 / 14 * 13),
                 .init(white: 1.0)]

            ],
        "panttone":
            [
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

