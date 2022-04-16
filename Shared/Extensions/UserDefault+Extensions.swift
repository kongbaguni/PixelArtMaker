//
//  UserDefault+Extensions.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/22.
//

import SwiftUI
extension UserDefaults {
    var lastColorPresetIndexPath:IndexPath {
        set {
            lastColorPresetSelectionIndex = newValue.section
            lastColorPresetRowSelectionIndex = newValue.row
        }
        get {
            let section = lastColorPresetSelectionIndex
            let row = lastColorPresetRowSelectionIndex
            return .init(row: row, section: section)
        }
    }
    
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
    
    var paintRange:Int {
        set {
            set(newValue, forKey: "paintRange")
        }
        get {
            integer(forKey: "paintRange")
        }
    }
    
    var transparencyIndex:Int {
        set {
            set(newValue, forKey: "transparencyIndex")
        }
        get {
            integer(forKey: "transparencyIndex")
        }
    }
    
    var transparencyColor:(a:UIColor,b:UIColor) {
        set {
            let v = newValue
            let a = CIColor(color:v.a)
            let b = CIColor(color:v.b)
            set(Float(a.red), forKey: "transparencyColor_a_red")
            set(Float(a.green), forKey: "transparencyColor_a_green")
            set(Float(a.blue), forKey: "transparencyColor_a_blue")
            set(Float(a.alpha), forKey: "transparencyColor_a_alpha")
            set(Float(b.red), forKey: "transparencyColor_b_red")
            set(Float(b.green), forKey: "transparencyColor_b_green")
            set(Float(b.blue), forKey: "transparencyColor_b_blue")
            set(Float(b.alpha), forKey: "transparencyColor_b_alpha")
        }
        get {
            let a = [
                CGFloat(float(forKey: "transparencyColor_a_red")),
                CGFloat(float(forKey: "transparencyColor_a_green")),
                CGFloat(float(forKey: "transparencyColor_a_blue")),
                CGFloat(float(forKey: "transparencyColor_a_alpha"))
            ]
            let b = [
                CGFloat(float(forKey: "transparencyColor_b_red")),
                CGFloat(float(forKey: "transparencyColor_b_green")),
                CGFloat(float(forKey: "transparencyColor_b_blue")),
                CGFloat(float(forKey: "transparencyColor_b_alpha"))
            ]

            let empty:[CGFloat] = [0.0,0.0,0.0,0.0]
            if a == empty && a == empty {
                return (a:UIColor(white: 0.8, alpha: 1.0), b:.white)
            }
            let colora = UIColor(red: a[0], green: a[1], blue: a[2], alpha: a[3])
            let colorb = UIColor(red: b[0], green: b[1], blue: b[2], alpha: b[3])
            return(a:colora,b:colorb)
        }
    }
    

    var colorPaletteIsLock:Bool {
        set {
            set(newValue, forKey: "colorPalleteIsLock")
        }
        get {
            bool(forKey: "colorPalleteIsLock")
        }
    }
}
