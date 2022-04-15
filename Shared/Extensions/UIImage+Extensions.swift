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
    /** 이미지 줌 영역 표시 위한 이미지 만들기*/
    public convenience init?(offset:(x:Int,y:Int),frame:(width:Int,height:Int), size:CGSize, backgroundColor:UIColor, AreaLineColor:UIColor) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        backgroundColor.setFill()
        UIRectFillUsingBlendMode(.init(x: 0, y: 0, width: size.width, height: size.height), .normal)

        AreaLineColor.setFill()
        
        UIRectFill(.init(x: offset.x, y: offset.y, width: frame.width, height: frame.height))
        
        backgroundColor.setFill()
        UIRectFill(.init(x: offset.x + 1, y: offset.y + 1, width: frame.width - 2, height: frame.height - 2))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage:cgImage)
    }
    
    // 새 켄버스의  미리보기 이미지 만들기
    public convenience init?(pixelSize:(width:Int,height:Int), backgroundColor:Color, size:CGSize, transparencyColor:(a:UIColor,b:UIColor)? = nil) {
        let tColor = transparencyColor ?? UserDefaults.standard.transparencyColor
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                
        UIRectFillUsingBlendMode(.init(x: 0, y: 0, width: size.width, height: size.height), .normal)

        let w = size.width / CGFloat(pixelSize.width)
        let h = size.height / CGFloat(pixelSize.height)

        if backgroundColor.ciColor.alpha < 1.0 {
            for y in 0..<pixelSize.height {
                for x in 0..<pixelSize.width {
                    let isGray = ((y % 2) + x) % 2 == 0
                    if isGray {
                        tColor.a.setFill()
                    } else {
                        tColor.b.setFill()
                    }
                    let rect:CGRect = .init(x: CGFloat(x) * w, y: CGFloat(y) * h, width: w, height: h)
                    UIRectFill(rect)
                }
            }
        }
        
        backgroundColor.uiColor.setFill()
        UIRectFillUsingBlendMode(.init(origin: .zero, size: size), .normal)
        
        for y in 0..<pixelSize.height {
            for x in 0..<pixelSize.height {
                let color:UIColor = .yellow
                color.setFill()
                let rect:CGRect = .init(x: CGFloat(x) * w,
                                        y: CGFloat(y) * h,
                                        width: w,
                                        height: h)
                UIRectFrameUsingBlendMode(rect, .normal)
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage:cgImage)
    }
    
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
                        if i < blendModes.count {
                            UIRectFillUsingBlendMode(rect, blendModes.reversed()[i])
                        }
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
    
    
    var squareImage:UIImage {
        if size.width > size.height {
            let offsetx = (size.width - size.height) / 2
            let rect = CGRect(x: offsetx, y: 0, width: size.height, height: size.height)
            if let image = cgImage?.cropping(to: rect) {
                return UIImage(cgImage: image)
            }
        }
        else if size.width < size.height {
            let offsety = (size.height - size.width) / 2
            let rect = CGRect(x: 0, y: offsety, width: size.width, height: size.width)
            if let image = cgImage?.cropping(to: rect) {
                return UIImage(cgImage: image)
            }
        }
        return self
    }
    
    // 세로 이미지 회전 문제로 인한 함수

    var fixOrientationImage: UIImage {
        if (imageOrientation == .up) {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
