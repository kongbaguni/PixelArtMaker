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

    let likeReplyCollection = Firestore.firestore().collection("replylike")
    
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
    func getReplysToMe(uid:String,  limit:Int,complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
        var query = collection
            .order(by: "uid")
            .whereField("uid", isNotEqualTo: uid)
            .order(by: "updateDt", descending: true)
            .whereField("documentsUid", isEqualTo: uid)
            
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
    
    func likeToggle(replyId:String, complete:@escaping(_ isLike:Bool, _ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            return
        }
        let id = "\(uid)_\(replyId)"
        likeReplyCollection.document(id).getDocument {[self] snapshot, error1 in
            if snapshot?.data() == nil {
                let data:[String:AnyHashable] = [
                    "uid":uid,
                    "replyId":replyId,
                    "updateDt":Date().timeIntervalSince1970
                ]
                likeReplyCollection.document(id).setData(data) { error2 in
                    complete(true, error1 ?? error2)
                }
            } else {
                likeReplyCollection.document(id).delete { error2 in
                    complete(false, error1 ?? error2)
                }
            }
        }
    }
    
    func getLikeList(replyId:String, complete:@escaping(_ uids:[String], _ error: Error?)->Void) {
        likeReplyCollection.order(by: "updateDt", descending: true)
            .whereField("replyId", isEqualTo: replyId)
            .getDocuments { snapshot, error in
                let ids = (snapshot?.documents ?? []).map({ snap in
                    return snap.data()["uid"] as! String
                })
                complete(ids, error)
            }
        
    }
    
    func isMyLike(replyId:String, complete:@escaping(_ isMyLike:Bool, _ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            return
        }
        let id = "\(uid)_\(replyId)"
        likeReplyCollection.document(id).getDocument { snapshot, error in
            complete(snapshot?.data() != nil, error)
        }
    }
}
