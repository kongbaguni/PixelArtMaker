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
}
