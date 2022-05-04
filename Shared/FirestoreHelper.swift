//
//  FirestoreHelper.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/29.
//

import Foundation
import FirebaseFirestore
import RealmSwift

extension Notification.Name {
    /** 댓글 지워짐*/
    static let replyDidDeleted = Notification.Name("replyDidDeleted_observer")
    /** 좋아요 변경으로  다시 읽어야함*/
    static let likeArticleDataDidChange = Notification.Name("likeArticleDataDidChange_observer")
}

struct FirestoreHelper {
    struct Profile {
        static func createDefault(complete:@escaping(_ isSucess:Bool)->Void) {
            guard let uid = AuthManager.shared.userId else {
                complete(false)
                return
            }
            DispatchQueue.global().async {
                let collection = Firestore.firestore().collection("profile")
                let data:[String:AnyHashable] = [
                    "uid":uid,
                    "email":AuthManager.shared.auth.currentUser?.email ?? "",
                    "nickname":AuthManager.shared.auth.currentUser?.displayName ?? AuthManager.shared.auth.currentUser?.email ?? "",
                    "profileURL":AuthManager.shared.auth.currentUser?.photoURL?.absoluteString ?? "",
                    "updateDt":Date().timeIntervalSince1970
                ]
                collection.document(uid).setData(data) { error in
                    print(error?.localizedDescription ?? "성공")
                    DispatchQueue.main.async {
                        complete(error == nil)
                    }
                }
            }
        }

        static func findBy(uid:String, complete:@escaping(_ error:Error?)->Void) {
            DispatchQueue.global().async {
                let collection = Firestore.firestore().collection("profile")
                collection.document(uid).getDocument { snapShot, error in
                    if let data = snapShot?.data() {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.create(ProfileModel.self, value: data, update: .all)
                        }
                        DispatchQueue.main.async {
                            complete(error)
                        }
                    }
                }
            }
        }

        static func downloadProfile(uid:String? = AuthManager.shared.userId, isCreateDefaultProfile:Bool,complete:@escaping(_ error:Error?)->Void) {
            guard let uid = uid else {
                complete(nil)
                return
            }
            if uid == "" {
                complete(nil)
                return
            }
            
            DispatchQueue.global().async {
                let collection = Firestore.firestore().collection("profile")
                collection.document(uid).getDocument { snapShot, error in
                    if error == nil && snapShot?.data() == nil && isCreateDefaultProfile {
                        createDefault { isSucess in
                            downloadProfile(isCreateDefaultProfile:false ,complete: complete)
                        }
                        return
                    }
                    if let data = snapShot?.data() {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.create(ProfileModel.self, value: data, update: .modified)
                            DispatchQueue.main.async {
                                complete(error)
                            }
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        complete(error)
                    }
                }
            }
        }
        
        static func updateProfile(nickname:String, introduce:String? = nil, profileImageRefId:String? = nil, email:String? = nil, complete:@escaping(_ error:Error?)->Void) {
            DispatchQueue.global().async {                
                if nickname.replacingOccurrences(of: " ", with: "").isEmpty == true {
                    complete(nil)
                    return
                }
                guard let uid = AuthManager.shared.userId else {
                    complete(nil)
                    return
                }
                var data:[String:AnyHashable] = [
                    "uid":uid,
                    "nickname":nickname,
                    "updateDt":Date().timeIntervalSince1970
                ]
                if let txt = introduce {
                    data["introduce"] = txt
                }
                if let id = profileImageRefId {
                    data["profileImageRefId"] = id
                }
                if let email = email {
                    data["email"] = email
                }
                let collection = Firestore.firestore().collection("profile")
                collection.document(uid).updateData(data) { error in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .profileDidUpdated, object: nil)
                        complete(error)
                    }
                }
            }
        }
        
        static func updatePhoto(photoRefId:String, complete:@escaping(_ error:Error?)->Void) {
            guard let uid = AuthManager.shared.userId else {
                complete(nil)
                return
            }
            DispatchQueue.global().async {                
                let collection = Firestore.firestore().collection("profile")
                let data:[String:AnyHashable] = [
                    "uid":uid,
                    "profileImageRefId":photoRefId,
                    "updateDt":Date().timeIntervalSince1970
                ]
                collection.document(uid).updateData(data) { error in
                    if error == nil {
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.create(ProfileModel.self, value: data, update: .modified)
                        try! realm.commitWrite()
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .profileDidUpdated, object: nil)
                        complete(error)
                    }
                }
            }
        }
    }
    //MARK: - 공개 개시글
    /** 공개 개시글 관련 */
    struct PublicArticle {
        /** 개시글 목록 조회 */
        static func getList(uid:String,isLimited:Bool, ids:[String],  complete:@escaping(_ result:[String], _ error:Error?)->Void) {
            DispatchQueue.global().async {
                
                var query = Firestore.firestore().collection("public").whereField("uid", isEqualTo: uid)
                query = query.order(by: "updateDt", descending: true)
                
                if isLimited == false {
                    if let last = ids.last {
                        if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: last) {
                            query = query.whereField("updateDt", isLessThan: model.updateDt)
                        }
                    }
                }
                query = query.limit(to: Consts.profileImageLimit)
                
                query.getDocuments { snapshot, error in
                    let realm = try! Realm()
                    var result:[String] = []
                    if let documents = snapshot?.documents {
                        realm.beginWrite()
                        for doc in documents {
                            var data = doc.data()
                            data["id"] = doc.documentID
                            realm.create(SharedStageModel.self, value: data, update: .modified)
                            result.append(doc.documentID)
                        }
                        try! realm.commitWrite()
                    }
                    DispatchQueue.main.async {
                        complete(result, error)
                    }
                }
            }
        }
        /** 좋아요 한 개시글 목록 가져오기*/
        static func getLikeList(uid:String, list:[LikeModel],isLimited:Bool, complete:@escaping(_ result:[LikeModel], _ error:Error?)->Void) {
            DispatchQueue.global().async {
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
                        DispatchQueue.main.async {
                            complete(ids, error)
                        }
                    } else {
                        DispatchQueue.main.async {
                            complete([], error)
                        }
                    }
                }
            }
        }
        /** 개시글 정보 가져오기*/
        static func open(id:String, complete:@escaping(_ error:Error?)->Void) {
            DispatchQueue.global().async {
                Firestore.firestore().collection("public").document(id).getDocument { snapShot, error in
                    if var data = snapShot?.data(), let id = snapShot?.documentID {
                        data["id"] = id
                        let realm = try! Realm()
                        try! realm.write {
                            realm.create(SharedStageModel.self, value: data, update: .all)
                        }
                    }
                    DispatchQueue.main.async {
                        complete(error)
                    }
                }
            }
        }
        
        // MARK: - 개시글 좋아요
        /** 개시글 좋아요 토글 */
        static func toggleArticleLike(documentId:String, imageRefId:String, complete:@escaping(_ isLike:Bool, _ uids:[String], _ error:Error?)->Void) {
            guard let uid = AuthManager.shared.userId else {
                return
            }
            let id = "\(documentId),\(uid)"
            let data:[String:AnyHashable] = [
                "documentId":documentId,
                "imageRefId":imageRefId,
                "uid":uid,
                "updateDt":Date().timeIntervalSince1970,
            ]
                   
            let newModel = LikeModel(documentId: documentId, uid: uid, imageRefId: imageRefId, updateDt: Date().timeIntervalSince1970)
            
            let collection = Firestore.firestore().collection("like")
            collection.document(id).getDocument { snapShot, error1 in
                if snapShot?.data() != nil {
                    collection.document(id).delete { error2 in
                        getLikePeopleIds(documentId: documentId) { uids, error3 in
                            complete(false, uids, error1 ?? error2 ?? error3)

                            
                            NotificationCenter.default.post(name: .likeArticleDataDidChange, object: newModel, userInfo: [
                                "documentId":documentId,
                                "uid":uid,
                                "isLike":false,
                                "likePeopleUids":uids
                            ])
                        }
                    }
                } else {
                    collection.document(id).setData(data) { error2 in
                        getLikePeopleIds(documentId: documentId) { uids, error3 in
                            complete(true, uids, error1 ?? error2 ?? error3)
                            NotificationCenter.default.post(name: .likeArticleDataDidChange, object: newModel, userInfo: [
                                "documentId":documentId,
                                "uid":uid,
                                "isLike":true,
                                "likePeopleUids":uids
                            ])
                        }
                    }
                }
            }
        }
        
        /** 개시글을 좋아요 한 사람  구하기*/
        static func getLikePeopleIds(documentId:String, complete:@escaping(_ uids:[String], _ error:Error?)->Void) {
            let collection = Firestore.firestore().collection("like")
            collection.whereField("documentId", isEqualTo: documentId)
                .order(by: "updateDt", descending: true)
                .getDocuments { snapShot, error in
                if let documents = snapShot?.documents {
                    let ids = documents.map({ snapShot in
                        return snapShot.data()["uid"] as! String
                    })
                    complete(ids, error)

                }
                
            }
        }
    }
        
//    MAKR:- 댓글
    struct Reply {
        /** 댓글 쓰기*/
        static func add(replyModel:ReplyModel,complete:@escaping(_ error:Error?)->Void) {
            guard let data = replyModel.jsonValue else {
                return
            }
                    
            DispatchQueue.global().async {
                Firestore.firestore().collection("reply").document(replyModel.id).setData(data) { error in
                    DispatchQueue.main.async {
                        complete(error)
                    }
                }
            }
        }
        
        /** 게시글에 달린 댓글 목록*/
        static func getReplys(documentId:String, limit:Int, complete:@escaping(_ result:[ReplyModel], _ error:Error?)->Void) {
            DispatchQueue.global().async {
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
                    DispatchQueue.main.async {
                        complete(result.sorted(by: { a, b in
                            a.updateDt < b.updateDt
                        }),error)
                    }
                }
            }
        }
        
        /** 댓글 삭제*/
        static func delete(id:String, complete:@escaping(_ error:Error?)->Void) {
            DispatchQueue.global().async {
                Firestore.firestore().collection("reply").document(id).delete { error in
                    DispatchQueue.main.async {
                        complete(error)
                        if error == nil {
                            NotificationCenter.default.post(name: .replyDidDeleted, object: id)
                        }
                    }
                }
            }
        }
        
        /** 내가 단 댓글 목록 */
        static func getReplys(uid:String, replys:[ReplyModel]? = nil, complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
            DispatchQueue.global().async {
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
                    DispatchQueue.main.async {
                        complete(result.sorted(by: { a, b in
                            a.updateDt > b.updateDt
                        }),error)
                    }
                }
            }
        }
        
        /** 내 게시글에 달린 댓글 목록*/
        static func getReplysToMe(uid:String, replys:[ReplyModel]? = nil, complete:@escaping(_ result:[ReplyModel], _ error:Error?)-> Void) {
            DispatchQueue.global().async {
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
                    DispatchQueue.main.async {
                        complete(result.sorted(by: { a, b in
                            a.updateDt > b.updateDt
                        }),error)
                    }
                }
            }
        }
        
        /** 좋아요 토글 */
        static func likeToggle(replyId:String, complete:@escaping(_ isLike:Bool, _ error:Error?)->Void) {
            guard let uid = AuthManager.shared.userId else {
                return
            }
            DispatchQueue.global().async {
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
                            DispatchQueue.main.async {
                                complete(true, error1 ?? error2)
                            }
                        }
                    } else {
                        likeReplyCollection.document(id).delete { error2 in
                            DispatchQueue.main.async {
                                complete(false, error1 ?? error2)
                            }
                        }
                    }
                }
            }
        }
        
        /** 특정 댓글을 좋아요 한 사람 목록 */
        static func getLikePeopleList(replyId:String, complete:@escaping(_ uids:[String], _ error: Error?)->Void) {
            DispatchQueue.global().async {
                Firestore.firestore().collection("replylike").order(by: "updateDt", descending: true)
                    .whereField("replyId", isEqualTo: replyId)
                    .getDocuments { snapshot, error in
                        let ids = (snapshot?.documents ?? []).map({ snap in
                            return snap.data()["uid"] as! String
                        })
                        
                        DispatchQueue.main.async {
                            complete(ids, error)
                        }
                    }
            }
        }
        

        /** 좋아요한 댓글 목록*/
        static func getLikeReplyList(uid:String, replys:[ReplyModel]? = nil, lastUpdateDt:TimeInterval? = nil ,complete:@escaping(_ replys:[ReplyModel], _ error : Error?)-> Void) {
            DispatchQueue.global().async {
                
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
            DispatchQueue.global().async {
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
                    var result:[ReplyModel] = []
                    if let documents = snapShot?.documents {
                        for doc in documents {
                            let json = doc.data() as [String:AnyObject]
                            if let model = ReplyModel.makeModel(json: json)  {
                                result.append(model)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        complete(result,error)
                    }
                }

            }
        }
        
    }
   
   
    
    
    struct Timeline {
        static func read(articleId:String, isRead:Bool, complete:@escaping(_ count:Int, _ error:Error?)->Void) {
            DispatchQueue.global().async {
                guard let uid = AuthManager.shared.userId else {
                    return
                }
                let readCountCollection = Firestore.firestore().collection("public_read")
                if isRead {
                    let data:[String:AnyHashable] = [
                        "articleId":articleId,
                        "uid":uid,
                        "updateDt":Date().timeIntervalSince1970
                    ]
                    
                    readCountCollection.document("\(uid)_\(articleId)").setData(data) { error in
                        if error == nil {
                            read(articleId: articleId, isRead: false, complete: complete)
                        }
                    }
                    return
                }
                
                readCountCollection.whereField("articleId", isEqualTo: articleId).getDocuments { snapShot, error in
                    complete(snapShot?.count ?? 0, error)
                }
            }
        }
        
        static func getTimeLine(order:Sort.SortType, indexDt:TimeInterval? = nil , isLast:Bool = true, limit:Int, complete:@escaping(_ resultIds:[String], _ error:Error?)->Void) {
            DispatchQueue.global().async {
                let collection = Firestore.firestore().collection("public")
                var query:FirebaseFirestore.Query? = nil
                switch order {
                case .latestOrder:
                    query = collection.order(by: "updateDt", descending: true)
                    if let interval = indexDt {
                        if isLast {
                            query = query?.whereField("updateDt", isLessThan: interval)
                        } else {
                            query = query?.whereField("updateDt", isGreaterThan: interval)
                        }
                    }
                case .oldnet:
                    query = collection.order(by: "updateDt", descending: false)
                    if let interval = indexDt {
                        if isLast {
                            query = query?.whereField("updateDt", isGreaterThan: interval)
                        } else {
                            DispatchQueue.main.async {
                                complete([], nil)
                            }
                            return
                        }
                    }
                case .like:
                    query = collection.order(by: "likeCount", descending: true)
                }
                if limit > 0 {
                    query = query?.limit(to: limit)
                }
                query?.getDocuments(completion: { snapShot, error in
                    if let list = snapShot?.documents {
                        DispatchQueue.main.async {
                            complete  (
                                list.map { snapShot in
                                    return writeDb(snapshot: snapShot)
                                },
                                error
                            )
                        }
                    } else {
                        DispatchQueue.main.async {
                            complete([], error)
                        }
                    }
                })
            }

        }
        
        private static func writeDb(snapshot:QueryDocumentSnapshot)->String {
            var parm = snapshot.data()
            parm["id"] = snapshot.documentID
            let realm = try! Realm()
            realm.beginWrite()
            realm.create(SharedStageModel.self, value: parm, update: .all)
            try! realm.commitWrite()
            return parm["id"] as? String ?? ""
        }
        
        private static func loadFromLocalDB()->[String] {
            let realm = try! Realm()
            let list = realm.objects(SharedStageModel.self)
                .sorted(byKeyPath: "updateDt", ascending: false)
                .filter("deleted != %@", true)
            var result:[String] = []
            for model in list {
                result.append(model.id)
            }
            return result
        }
    }
}
