//
//  FirestoreHelper.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/29.
//

import Foundation
import FirebaseFirestore
import RealmSwift


struct FirestoreHelper {
    //MARK: - 공개 개시글 목록 가져오기
    static func getPublicArticle(uid:String,isLimited:Bool, ids:[String], sort:Sort.SortType, complete:@escaping(_ result:[String], _ error:Error?)->Void) {
        var query = Firestore.firestore().collection("public").whereField("uid", isEqualTo: uid)
        
        switch sort {
        case .latestOrder:
            query = query.order(by: "updateDt", descending: true)
        case .oldnet:
            query = query.order(by: "updateDt", descending: false)
        case .like:
            query = query.order(by: "likeCount", descending: true)
        }
        
        if isLimited == false {
            if let last = ids.last {
                if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: last) {
                    switch sort {
                    case .latestOrder:
                        query = query.whereField("updateDt", isLessThan: model.updateDt)
                    case .oldnet:
                        query = query.whereField("updateDt", isGreaterThan: model.updateDt)
                    case .like:
                        break
                    }
                }
            }
        }
        switch sort {
        case .like:
            query = query.limit(to: Consts.likeSortLimit)
        default:
            query = query.limit(to: Consts.profileImageLimit)
        }

        query.getDocuments { snapshot, error in
            let realm = try! Realm()
            if let documents = snapshot?.documents {
                var result:[String] = []
                realm.beginWrite()
                for doc in documents {
                    var data = doc.data()
                    data["id"] = doc.documentID
                    realm.create(SharedStageModel.self, value: data, update: .modified)
                    result.append(doc.documentID)
                }
                try! realm.commitWrite()
                complete(result, error)
            } else {
                complete([],error)
            }
        }
    }
    /** 좋아요 한 개시글 목록 가져오기*/
    static func getLikeArticleList(uid:String, list:[LikeModel],isLimited:Bool, complete:@escaping(_ result:[LikeModel], _ error:Error?)->Void) {
        var query = Firestore.firestore().collection("like").order(by: "updateDt", descending: true)
            .whereField("uid", isEqualTo: uid)
        if let updateDt = list.last?.updateDt {
            if isLimited == false {
                query = query.whereField("updateDt", isLessThan: updateDt)
            }
        }
        query = query.limit(to: Consts.profileImageLimit)
        query.getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                let ids = docs.map { ds in
                    return LikeModel.makeModel(json: ds.data()) ?? .init(documentId: "", uid: "", imageRefId: "", updateDt: 0)
                }
                complete(ids, error)
            } else {
                complete([], error)
            }
        }
    }
    /** 개시글 정보 가져오기*/
    static func getArticle(id:String, complete:@escaping(_ error:Error?)->Void) {
        Firestore.firestore().collection("public").document(id).getDocument { snapShot, error in
            if var data = snapShot?.data(), let id = snapShot?.documentID {
                data["id"] = id
                let realm = try! Realm()
                try! realm.write {
                    realm.create(SharedStageModel.self, value: data, update: .all)
                }
            }
            complete(error)
        }
    }
        
//    MAKR:- 댓글
    
    /** 댓글 쓰기*/
    static func addReply(replyModel:ReplyModel,complete:@escaping(_ error:Error?)->Void) {
        guard let data = replyModel.jsonValue else {
            return
        }
                
        Firestore.firestore().collection("reply").document(replyModel.id).setData(data) { error in
            complete(error)
        }
    }
    
    /** 게시글에 달린 댓글 목록*/
    static func getReplys(documentId:String, limit:Int, complete:@escaping(_ result:[ReplyModel], _ error:Error?)->Void) {
        var query = Firestore.firestore().collection("reply").order(by: "updateDt", descending: true).whereField("documentId", isEqualTo: documentId)
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
    /** 댓글 삭제*/
    static func deleteReply(id:String, complete:@escaping(_ error:Error?)->Void) {
        Firestore.firestore().collection("reply").document(id).delete { error in
            complete(error)
        }
    }
    
    /** 내가 단 댓글 목록 */
    static func getReplys(uid:String, replys:[ReplyModel]? = nil, complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
        var query = Firestore.firestore().collection("reply").order(by: "updateDt", descending: true).whereField("uid", isEqualTo: uid)
        
        if let list = replys, let dt = replys?.last?.updateDt {
            if list.count % Consts.profileReplyLimit == 0 {
                query = query.whereField("updateDt", isLessThan: dt)
            }
        }
        query = query.limit(to: Consts.profileReplyLimit)

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
    static func getReplysToMe(uid:String, replys:[ReplyModel]? = nil, complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
        var query = Firestore.firestore().collection("reply").order(by: "updateDt", descending: true)
        if let list = replys, let dt = replys?.last?.updateDt {
            if list.count % Consts.profileReplyLimit == 0 {
                query = query.whereField("updateDt", isLessThan: dt)
            }
        }

        query = query
            .whereField("documentsUid", isEqualTo: uid)
            .limit(to: Consts.profileReplyLimit)

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
    
    /** 좋아요 토글 */
    static func likeToggle(replyId:String, complete:@escaping(_ isLike:Bool, _ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            return
        }
        let id = "\(uid)_\(replyId)"
        let likeReplyCollection = Firestore.firestore().collection("replylike")
        
        likeReplyCollection.document(id).getDocument { snapshot, error1 in
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
    
    /** 특정 댓글을 좋아요 한 사람 목록 */
    static func getLikePeopleList(replyId:String, complete:@escaping(_ uids:[String], _ error: Error?)->Void) {
        Firestore.firestore().collection("replylike").order(by: "updateDt", descending: true)
            .whereField("replyId", isEqualTo: replyId)
            .getDocuments { snapshot, error in
                let ids = (snapshot?.documents ?? []).map({ snap in
                    return snap.data()["uid"] as! String
                })
                complete(ids, error)
            }
        
    }
    

    /** 좋아요한 댓글 목록*/
    static func getLikeReplyList(uid:String, replys:[ReplyModel]? = nil, lastUpdateDt:TimeInterval? = nil ,complete:@escaping(_ replys:[ReplyModel], _ error : Error?)-> Void) {
        let likeReplyCollection = Firestore.firestore().collection("replylike")
        var query = likeReplyCollection.order(by: "updateDt", descending: true)
            .whereField("uid", isEqualTo: uid)

        
        if let lastId = replys?.last?.id {
            likeReplyCollection.document("\(uid)_\(lastId)").getDocument { [self] snapShot, error in
                if let data = snapShot?.data(),
                   let dt = data["updateDt"] as? TimeInterval {
                    getLikeReplyList(uid: uid, replys: nil, lastUpdateDt: dt, complete: complete)
                }
            }
            return
        }
        if let lastUpdateDt = lastUpdateDt {
            query = query.whereField("updateDt", isLessThan: lastUpdateDt)
        }
        query = query.limit(to: Consts.profileReplyLimit)
        
        DispatchQueue.global().async {
            query.getDocuments { snapshot, error in
                let ids = (snapshot?.documents ?? []).map({ snap in
                    return snap.data()["replyId"] as! String
                })
                var replys:[ReplyModel] = []
                var replyCount = 0
                for id in ids {
                    replys.append(.init(documentId: "" , documentsUid: "", message: "", imageRefId: "", replyId: id))
                }
                if ids.count == 0 {
                    complete([],error)
                    return
                }
                for (idx,id) in ids.enumerated() {
                    Firestore.firestore().collection("reply").document(id).getDocument { rsnapShot, error in
                        if let err = error {
                            complete([], err)
                            return
                        }
                        if let data = rsnapShot?.data() {
                            let json = data as [String:AnyObject]
                            if let model = ReplyModel.makeModel(json: json)  {
                                replys[idx] = model
                            }
                                                                                    
                        }
                        
                        replyCount += 1
                        if replyCount == ids.count {
                            DispatchQueue.main.async {
                                complete(replys, nil)
                            }
                        }

                       
                    }
                }
                
            }

        }
    }
    
    
    static func getReplyTopicList(indexReply:ReplyModel?, isLast:Bool, complete:@escaping(_ replys:[ReplyModel], _ error: Error?)->Void) {
        var query = Firestore.firestore().collection("reply")
            .order(by: "updateDt", descending: true)
            
        if let lastReply = indexReply {
            if isLast {
                query = query.whereField("updateDt", isLessThan: lastReply.updateDt)
            } else {
                query = query.whereField("updateDt", isGreaterThan: lastReply.updateDt)
            }
        }
        query.limit(to: Consts.timelineLimit)
        
        query.getDocuments { snapShot, error in
            if let documents = snapShot?.documents {              
                var result:[ReplyModel] = []
                for doc in documents {
                    let json = doc.data() as [String:AnyObject]
                    if let model = ReplyModel.makeModel(json: json)  {
                        result.append(model)
                    }
                }
                complete(result, error)
            }
            else {
                complete([],error)
            }
        }
    }
}
