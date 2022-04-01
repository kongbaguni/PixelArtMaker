//
//  UIImage+Extensions.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/22.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage {
    public convenience init?(totalColors:[[[Color]]],blendModes:[CGBlendMode],backgroundColor:Color, size:CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if backgroundColor.ciColor.alpha > 0 {
            backgroundColor.uiColor.setFill()
            UIRectFillUsingBlendMode(.init(x: 0, y: 0, width: size.width, height: size.height), .normal)
        }
        for (i,colors) in totalColors.reversed().enumerated() {
            for (y,list) in colors.enumerated() {
                for (x,color) in list.enumerated() {
                    let ci = color.ciColor
                    if ci.alpha > 0 {
                        let color = UIColor(red: ci.red, green: ci.green, blue: ci.blue, alpha: ci.alpha)
                        color.setFill()
                        let w = size.width / CGFloat(colors.count)
                        let h = size.height / CGFloat(list.count)
                        let rect = CGRect(x: CGFloat(x) * w , y: CGFloat(y) * h  , width: w, height: h)
                        UIRectFillUsingBlendMode(rect, blendModes[i])
                    }
                }
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage:cgImage)
    }
    
    public convenience init?(base64encodedString str:String) {
        if let data = NSData(base64Encoded: str),
           let ddata = try? data.decompressed(using: .zlib) as Data {
            self.init(data: ddata)
            return
        }
        self.init()
    }
}
