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
    
    var lastGoogleAdWatchTime:Date? {
        set {
            set(newValue?.timeIntervalSince1970, forKey: "lastGoogleAdWatchTime")
        }
        get {            
            let value = double(forKey: "lastGoogleAdWatchTime")
            if value > 0 {
                return Date(timeIntervalSince1970: value)
            }
            return nil
        }
    }
    
    var lastInAppPurchaseExpireDate:Date? {
        set {
            set(newValue?.timeIntervalSince1970, forKey: "lastInAppPurchaseExpireDate")
        }
        get {
            let value = double(forKey: "lastInAppPurchaseExpireDate")
            if value > 0 {
                return Date(timeIntervalSince1970: value)
            }
            return nil
        }        
    }
}
