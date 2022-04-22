//
//  MyLikeModel.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/13.
//

import Foundation
import RealmSwift
class LikeModel : Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var uid:String = ""
    @Persisted var imageRefId:String = ""
    @Persisted var updateDt:TimeInterval = 0
    
    var documentId:String {
        return id.components(separatedBy: ",").last ?? id
    }
}
