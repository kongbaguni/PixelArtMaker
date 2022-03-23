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
    public convenience init?(totalColors:[[[Color]]],blandModes:[CGBlendMode],backgroundColor:Color, size:CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let p:CGFloat = 0.01
        let p2 = p * 2
        
        if backgroundColor.ciColor.alpha > 0 {
            backgroundColor.uiColor.setFill()
            UIRectFillUsingBlendMode(.init(x: 0, y: 0, width: size.width, height: size.height), .normal)
        }
        for (i,colors) in totalColors.enumerated() {
            for (y,list) in colors.enumerated() {
                for (x,color) in list.enumerated() {
                    let ci = color.ciColor
                    if ci.alpha > 0 {
                        let color = UIColor(red: ci.red, green: ci.green, blue: ci.blue, alpha: ci.alpha)
                        color.setFill()
                        let w = size.width / CGFloat(list.count)
                        let h = size.height / CGFloat(colors.count)
                        let rect = CGRect(x: CGFloat(x) * w - p , y: CGFloat(y) * h - p , width: w  + p2, height: h + p2 )
                        UIRectFillUsingBlendMode(rect, blandModes[i])
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
}
