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
}
