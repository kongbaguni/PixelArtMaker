//
//  LikeManager.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/20.
//

import Foundation
import FirebaseFirestore

extension Notification.Name {
    /** 좋아요 변경으로  다시 읽어야함*/
    static let likeArticleDataDidChange = Notification.Name("likeArticleDataDidChange_observer")
}
struct LikeManager {
    let collection = Firestore.firestore().collection("like")
    
    func toggleLike(documentId:String, imageRefId:String, complete:@escaping(_ isLike:Bool, _ uids:[String], _ error:Error?)->Void) {
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
                
        collection.document(id).getDocument { snapShot, error1 in            
            if snapShot?.data() != nil {
                collection.document(id).delete { error2 in
                    getLikeCount(documentId: documentId) { uids, error3 in
                        complete(false, uids, error1 ?? error2 ?? error3)
                        
                        NotificationCenter.default.post(name: .likeArticleDataDidChange, object: nil, userInfo: [
                            "documentId":documentId,
                            "uid":uid,
                            "isLike":true
                        ])
                    }
                }
            } else {
                collection.document(id).setData(data) { error2 in
                    getLikeCount(documentId: documentId) { uids, error3 in
                        complete(true, uids, error1 ?? error2 ?? error3)
                        NotificationCenter.default.post(name: .likeArticleDataDidChange, object: nil, userInfo: [
                            "documentId":documentId,
                            "uid":uid,
                            "isLike":false
                        ])
                    }
                }
            }
        }
    }
    
    func getLikeCount(documentId:String, complete:@escaping(_ uids:[String], _ error:Error?)->Void) {
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
