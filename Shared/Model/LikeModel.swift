//
//  MyLikeModel.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/13.
//

import Foundation
import RealmSwift
struct LikeModel : Codable, Hashable {
    public static func == (lhs:LikeModel, rhs:LikeModel)->Bool {
        return lhs.documentId == rhs.documentId && lhs.uid == rhs.uid && lhs.imageRefId == rhs.imageRefId
    }
    let documentId:String
    let uid:String
    let imageRefId:String
    let updateDt:TimeInterval
    
    static func makeModel(json:[String:Any])->LikeModel? {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return try? JSONDecoder().decode(LikeModel.self, from: data)
        }
        return nil
    }
}

