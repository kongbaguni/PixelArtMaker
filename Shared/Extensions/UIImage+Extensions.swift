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
    public convenience init?(totalColors:[[[Color]]], size:CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setBlendMode(.normal)
        for colors in totalColors {
            for (y,list) in colors.enumerated() {
                for (x,color) in list.enumerated() {
                    let ci = color.ciColor
                    UIColor(red: ci.red, green: ci.green, blue: ci.blue, alpha: ci.alpha).setFill()
                    let w = size.width / CGFloat(list.count)
                    let h = size.height / CGFloat(colors.count)
                    let rect = CGRect(x: CGFloat(x) * w - 2, y: CGFloat(y) * h - 2, width: w + 4, height: h + 4)
                    ctx.setAlpha(ci.alpha)
                    UIRectFill(rect)
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
