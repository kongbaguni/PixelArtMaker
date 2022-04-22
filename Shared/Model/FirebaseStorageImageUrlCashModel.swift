//
//  FirebaseStorageImageUrlCashModel.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/22.
//

import Foundation
import RealmSwift
class FirebaseStorageImageUrlCashModel : Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var url:String = ""
    @Persisted var date:Date = Date()
    
    var isExpire:Bool {
        return Date().timeIntervalSince1970 - date.timeIntervalSince1970 > 60 * 60 
    }
        
    var imageUrl:URL? {
        if url.isEmpty {
            return nil 
        }
        return URL(string:url)
    }
}
