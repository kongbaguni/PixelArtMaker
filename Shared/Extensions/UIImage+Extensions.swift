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
    public convenience init?(totalColors:[[[Color]]],backgroundColor:Color,size:CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let p:CGFloat = 1.0 / 20
        if backgroundColor.ciColor.alpha > 0 {
            backgroundColor.uiColor.setFill()
            UIRectFillUsingBlendMode(.init(x: 0, y: 0, width: size.width, height: size.height), .normal)
        }
        for colors in totalColors {
            for (y,list) in colors.enumerated() {
                for (x,color) in list.enumerated() {
                    let ci = color.ciColor
                    if ci.alpha > 0 {
                        UIColor(red: ci.red, green: ci.green, blue: ci.blue, alpha: ci.alpha).setFill()
                        let w = size.width / CGFloat(list.count)
                        let h = size.height / CGFloat(colors.count)
                        let rect = CGRect(x: CGFloat(x) * w - p , y: CGFloat(y) * h - p , width: w  + p * 2, height: h + p * 2 )
                        UIRectFillUsingBlendMode(rect, .normal)
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
