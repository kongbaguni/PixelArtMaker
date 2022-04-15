//
//  TracingImageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/15.
//

import Foundation
import RealmSwift
import UIKit
class TracingImageModel : Object {
    @Persisted(primaryKey: true) var uid:String = ""
    @Persisted var data:Data = Data()
    @Persisted var opacity:Float = 0.5
}

extension TracingImageModel {
    static func save(imageData:PixelDrawView.TracingImageData) {
        let uid = AuthManager.shared.userId ?? "guest"
        let data:[String:AnyHashable] = [
            "uid" : uid,
            "data" : imageData.image.pngData()!,
            "opacity" : Float(imageData.opacity)
        ]
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.create(TracingImageModel.self, value: data, update: .all)
        try! realm.commitWrite()
    }
    
    static func delete() {
        let uid = AuthManager.shared.userId ?? "guest"
        let realm = try! Realm()
        if let model = realm.object(ofType: TracingImageModel.self, forPrimaryKey: uid) {
            realm.beginWrite()
            realm.delete(model)
            try! realm.commitWrite()
        }
    }
    
    var tracingImageData:PixelDrawView.TracingImageData {
        .init(image: UIImage(data: data)!, opacity: CGFloat(opacity))
    }
    
    static var myTracingImageData:PixelDrawView.TracingImageData? {
        let uid = AuthManager.shared.userId ?? "guest"
        let realm = try! Realm()
        return realm.object(ofType: TracingImageModel.self, forPrimaryKey: uid)?.tracingImageData
    }
}
