//
//  ReplyModel.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/18.
//

import Foundation
import SwiftUI

struct ReplyModel : Codable, Hashable {
    static func == (lhs:ReplyModel, rhs:ReplyModel) -> Bool {
        return lhs.documentId == rhs.documentId && lhs.uid == rhs.uid && lhs.message == rhs.message && lhs.updateDt == rhs.updateDt
    }
    let id:String
    /** 댓글이 달린 개시글의 아이디*/
    let documentId:String
    /** 댓글 달린 게시글 소유자의 아이디*/
    let documentsUid:String
    /** 댓글단 사람의 uid */
    let uid:String
    /** 댓글 내용 */
    let message:String
    /** 갱신일 */
    let updateDt:TimeInterval
    /** 댓글 단 그림의 REF ID*/
    let imageRefId:String
    
    init(documentId:String, documentsUid:String, message:String, imageRefId:String) {
        self.documentId = documentId
        self.message = message
        id = "\(AuthManager.shared.userId ?? "guest")_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
        uid = AuthManager.shared.userId ?? "guest"
        updateDt = Date().timeIntervalSince1970
        self.imageRefId = imageRefId
        self.documentsUid = documentsUid
    }
    
}

extension ReplyModel {
    static func makeModel(json:[String:AnyObject])->ReplyModel? {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return try? JSONDecoder().decode(ReplyModel.self, from: data)
        }
        return nil
    }
    var jsonValue:[String:AnyObject]? {
        if let data = try? JSONEncoder().encode(self) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject] {
                return json
            }
        }
        return nil
    }

    var updateDtText:Text {
        let date = Date(timeIntervalSince1970: updateDt)
        return Text(date.formatted(date: .numeric, time: .standard))
    }
    
}

