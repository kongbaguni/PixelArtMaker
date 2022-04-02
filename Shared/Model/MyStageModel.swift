//
//  MyStageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/24.
//

import Foundation
import UIKit
import RealmSwift

class MyStageModel : Object {
    @Persisted(primaryKey: true) var documentId:String = ""
    @Persisted var imageData:Data!
    @Persisted var updateDt:Date = Date()
    @Persisted var shareDocumentId:String = ""
//    convenience init(documentId:String, image:UIImage, updateDt:Date) {
//        self.init()
//        self.documentId = documentId
//        self.imageData = image.pngData()
//        self.updateDt = updateDt
//    }
    
    var image:UIImage {
        UIImage(data: imageData)!
    }
}


