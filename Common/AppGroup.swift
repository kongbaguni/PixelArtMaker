//
//  AppGroup.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import WidgetKit
import SwiftUI

struct AppGroup {
    struct Color : Codable {
        let red:CGFloat
        let green:CGFloat
        let blue:CGFloat
        let alpha:CGFloat
        init(value:CIColor) {
            red = value.red
            green = value.green
            blue = value.blue
            alpha = value.alpha
        }
        
        var color:SwiftUI.Color {
            .init(red: red, green: green, blue: blue, opacity: alpha)
        }
    }
    
    struct ImageData : Codable {
        let size:CGSize
        let backgroundColor:Color
    }
    
    static var imageData:ImageData? {
        set {
            do {
                if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CommonConst.AppGroupId),
                   let data = newValue {
                    let fileURL = appGroupURL.appendingPathComponent(CommonConst.imageData)
                    try JSONEncoder().encode(data).write(to: fileURL)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        get {
            do {
                if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CommonConst.AppGroupId) {
                    let fileURL = appGroupURL.appendingPathComponent(CommonConst.imageData)
                    let data = try Data(contentsOf: fileURL)
                    let result = try JSONDecoder().decode(ImageData.self, from: data)
                    return result
                }
            } catch {
                print(error.localizedDescription)
            }
            
            return nil
        }
                
    }
    
    static var savedImage:UIImage? {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CommonConst.AppGroupId) {
            let fileURL = appGroupURL.appendingPathComponent(CommonConst.lastMyPictureName)
            if let data = try? Data(contentsOf: fileURL) {
                return UIImage(data: data)
            }
        }
        return nil
    }
}
