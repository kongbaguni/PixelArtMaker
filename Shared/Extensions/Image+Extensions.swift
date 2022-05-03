//
//  Image+Extensions.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/22.
//

import Foundation
import SwiftUI
import UIKit

fileprivate func saveFile(image:UIImage, key:String) {
    guard let data = image.pngData() else {
        return
    }
    do {
        if var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            path.appendPathComponent(key)
            try data.write(to: path)
        }
    } catch {
        print(error.localizedDescription)
    }
}

fileprivate func loadFile(key:String)->UIImage? {
    do {
        if var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            path.appendPathComponent(key)
            if FileManager.default.fileExists(atPath: path.path) {
                let data = try Data(contentsOf: path)
                return UIImage(data: data)
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    return nil
}

extension Image {
    static let imagePlaceHolder = Image("placeHolder").resizable()
    static let profilePlaceHolder = Image("profilePlaceholder").resizable()
    static let errorImage = Image("error").resizable()
    public init?(totalColors:[[[Color]]], blendModes:[CGBlendMode], backgroundColor: Color, size:CGSize) {
        let image = UIImage(totalColors: totalColors, blendModes: blendModes, backgroundColor: backgroundColor, size: size)!
        self.init(uiImage: image)
    }
    /** 새 켄버스의 미리보기 이미지 만들기 배경색 투명일 경우 체크무늬 이미지 */
    public init?(pixelSize:(width:Int,height:Int), backgroundColor:Color, size:CGSize) {
        let tcolor = UserDefaults.standard.transparencyColor
        let id = "\(pixelSize.width)_\(pixelSize.height)_\(backgroundColor)_\(size.width)_\(size.height)_\(tcolor.a)_\(tcolor.b)"
        if let image = loadFile(key: id) {
            self.init(uiImage: image)
            return
        }
        let image = UIImage(pixelSize: pixelSize, backgroundColor: backgroundColor, size: size)!
        saveFile(image: image, key: id)
        self.init(uiImage: image)
    }
    
    public init?(offset:(x:Int,y:Int),frame:(width:Int,height:Int), size:CGSize, backgroundColor:UIColor, AreaLineColor:UIColor) {
        let id = "\(offset.x)_\(offset.y)_\(frame.width)_\(frame.height)_\(size.width)_\(size.height)_\(backgroundColor)_\(AreaLineColor)"
        
        if let image = loadFile(key: id) {
            self.init(uiImage: image)
            return
        }
        
        let image = UIImage(offset: offset, frame: frame, size: size, backgroundColor: backgroundColor, AreaLineColor: AreaLineColor)!
        saveFile(image: image, key: id)
        self.init(uiImage: image)
    }
    
}

