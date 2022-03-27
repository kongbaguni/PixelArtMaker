//
//  SharedStageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import Foundation
import RealmSwift
import UIKit

class SharedStageModel : Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var documentId:String = ""
    @Persisted var email:String = ""
    @Persisted var image:String = ""
    @Persisted var regDt:TimeInterval = 0.0
    @Persisted var updateDt:TimeInterval = 0.0

    var imageValue:UIImage? {
        if let d = Data(base64Encoded: image) {
            return UIImage(data: d)
        }
        return nil
    }
    
    var regDate:Date {
        Date(timeIntervalSince1970: regDt)
    }
    
    var updateDate:Date {
        Date(timeIntervalSince1970: updateDt)
    }
}
