//
//  ReplyManager.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/18.
//

import Foundation
import FirebaseFirestore

class ReplyManager {
    static let shared = ReplyManager()
    
    let collection = Firestore.firestore().collection("reply")

    func addReply(replyModel:ReplyModel,complete:@escaping(_ error:Error?)->Void) {
        guard let data = replyModel.jsonValue else {
            return
        }
        
        collection.document(replyModel.id).setData(data) { error in
            complete(error)
        }
    }
    /** 게시글에 달린 댓글 목록*/
    func getReplys(documentId:String, limit:Int, complete:@escaping(_ result:[ReplyModel], _ error:Error?)->Void) {
        var query = collection.order(by: "updateDt", descending: true).whereField("documentId", isEqualTo: documentId)
        if limit > 0 {
            query = query.limit(to: limit)
        }
        query.getDocuments { snapShot, error in
                var result:[ReplyModel] = []

                if let documents = snapShot?.documents {
                    for doc in documents {
                        let json = doc.data() as [String:AnyObject]
                        if let model = ReplyModel.makeModel(json: json)  {
                            result.append(model)
                        }
                        
                    }
                }
                complete(result.sorted(by: { a, b in
                    a.updateDt < b.updateDt
                }),error)
            }
    }
    
    func deleteReply(id:String, complete:@escaping(_ error:Error?)->Void) {
        collection.document(id).delete { error in
            complete(error)
        }
    }
    
    /** 내가 단 댓글 목록 */
    func getReplys(uid:String, limit:Int, complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
        var query = collection.order(by: "updateDt", descending: true).whereField("uid", isEqualTo: uid)
        
        if limit > 0 {
            query = query.limit(to: limit)
        }
        query.getDocuments { snapShot, error in
            var result:[ReplyModel] = []

            if let documents = snapShot?.documents {
                for doc in documents {
                    let json = doc.data() as [String:AnyObject]
                    if let model = ReplyModel.makeModel(json: json)  {
                        result.append(model)
                    }
                    
                }
            }
            complete(result.sorted(by: { a, b in
                a.updateDt > b.updateDt
            }),error)
        }        
    }
    /** 내 게시글에 달린 댓글 목록*/
    func getReplysToMe(uid:String, limit:Int,complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
        var query = collection.order(by: "updateDt", descending: true).whereField("documentsUid", isEqualTo: uid)
        if limit > 0 {
            query = query.limit(to: limit)
        }
        query.getDocuments { snapShot, error in
            var result:[ReplyModel] = []

            if let documents = snapShot?.documents {
                for doc in documents {
                    let json = doc.data() as [String:AnyObject]
                    if let model = ReplyModel.makeModel(json: json)  {
                        result.append(model)
                    }
                    
                }
            }
            complete(result.sorted(by: { a, b in
                a.updateDt > b.updateDt
            }),error)
        }
        
    }
}
