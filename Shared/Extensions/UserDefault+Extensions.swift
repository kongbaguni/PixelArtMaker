//
//  UserDefault+Extensions.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/22.
//

import SwiftUI
extension UserDefaults {
    var lastColorPresetSelectionIndex:Int {
        set {
            set(newValue, forKey: "lastColorPresetSelectionIndex")
        }
        get {
            integer(forKey: "lastColorPresetSelectionIndex") 
        }
    }
    
    var lastColorPresetRowSelectionIndex:Int {
        set {
            set(newValue, forKey: "lastColorPresetRowSelectionIndex")
        }
        get {
            integer(forKey: "lastColorPresetRowSelectionIndex")
        }
    }
}
