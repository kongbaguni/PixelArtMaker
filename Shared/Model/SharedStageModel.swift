//
//  SharedStageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import Foundation
import RealmSwift
import UIKit
import FirebaseFirestore

class SharedStageModel : Object {
    struct ThreadSafeModel {
        let id:String
        let uid:String
        let documentId:String
        let email:String
        let regDt:Date
        let updateDt:Date
        let likeCount:Int
        let isMyLike:Bool
    }
    
    @Persisted(primaryKey: true) var id:String = ""
    /** 원본의 아이디 불러오기 구현시 참조용.*/
    @Persisted var documentId:String = ""
    @Persisted var uid:String = ""
    @Persisted var email:String = ""
    @Persisted var regDt:TimeInterval = 0.0
    @Persisted var updateDt:TimeInterval = 0.0
    @Persisted var deleted:Bool = false
    @Persisted var likeUids:String = ""
    @Persisted var likeCount:Int = 0    
    
    var regDate:Date {
        Date(timeIntervalSince1970: regDt)
    }
    
    var updateDate:Date {
        Date(timeIntervalSince1970: updateDt)
    }
    
    var isNew:Bool {
        Date().timeIntervalSince1970 - updateDt < 43200
    }
    
    var likeUserIds:[String] {
        let arr = likeUids.components(separatedBy: ",")
        var result:[String] = []
        for id in arr {
            if id.isEmpty {
                continue
            }
            result.append(id)
        }
        return result
    }
    
    var isMyLike:Bool {
        guard let uid = AuthManager.shared.userId else {
            return false
        }
        return likeUserIds.firstIndex(of: uid) != nil
    }
    
    var threadSafeModel:ThreadSafeModel {
        .init(id: id,
              uid: uid,
              documentId: documentId,
              email: email,
              regDt: Date(timeIntervalSince1970: regDt),
              updateDt: Date(timeIntervalSince1970: updateDt),
              likeCount: likeCount, isMyLike: isMyLike)
    }
    
}

fileprivate var collection = Firestore.firestore().collection("public")

fileprivate var myLikeCollection: CollectionReference? {
    if let uid = AuthManager.shared.userId {
        let collecion = Firestore.firestore().collection("pixelarts").document(uid).collection("like")
        return collecion
    }
    return nil
}

extension SharedStageModel {
    private func updateMyLikeList(isLike:Bool, complete:@escaping(_ error:Error?)->Void) {
        guard let collection = myLikeCollection, let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }
        let id = self.id
        var data:[String:Any] = [
            "id" : id,
            "uid" : uid,
            "imageRefId" : documentId,
            "updateDt" : Date().timeIntervalSince1970
        ]
        
        collection.whereField("id", isEqualTo: self.id).getDocuments { snapshot, error in
            if let err = error {
                complete(err)
                return
            }
                            
            if snapshot?.documents.count ?? 0 == 0 || (snapshot?.documents.first?.data()["deleted"] as? Bool) == true {
                //좋아요 없다
                if isLike == false {
                    complete(nil)
                    return
                } // 없으니까 만든다 (좋아요 추가함)
                collection.document(id).setData(data) { error in
                    complete(error)
                }
            } else {
                if isLike {
                    complete(nil)
                    return
                } // 있으니까 지운다. (좋아요 취소함)
                data["deleted"] = true
                data["imageRefId"] = ""
                
                collection.document(id).setData(data) { error in
                    let realm = try! Realm()
                    if let model = realm.object(ofType: LikeModel.self, forPrimaryKey: "\(uid),\(id)") {
                        realm.beginWrite()
                        realm.delete(model)
                        try! realm.commitWrite()
                    }
                    complete(error)
                }
            }
        }
        
    }
    
    func likeUpdate(isMyLike:Bool ,likeUids:[String], complete:@escaping(_ error:Error?)->Void) {
        if id.isEmpty {
            return
        }
        let id = self.id
        collection.document(id).getDocument { snapShot, error in
            if var data = snapShot?.data() {
                data["id"] = id

                let realm = try! Realm()
                realm.beginWrite()
                realm.create(SharedStageModel.self, value: data, update: .modified)
                try! realm.commitWrite()
                
                let updateData:[String:AnyHashable] = [
                    "id":id,
                    "likeUids" : likeUids.joined(separator: ","),
                    "likeCount" : likeUids.filter({ str in
                        return str.isEmpty == false
                    }).count
                ]
                
                realm.beginWrite()
                realm.create(SharedStageModel.self, value: updateData, update: .modified)
                try! realm.commitWrite()
                
                collection.document(id).updateData(updateData) { errorA in
                    self.updateMyLikeList(isLike: isMyLike) { errorB in
                        complete(errorA ?? errorB)
                    }
                }
            }
        }
    }
    
    
    static func findBy(id:String,complete:@escaping(_ error:Error?)->Void) {
        collection.document(id).getDocument { snapShot, error in
            if var data = snapShot?.data() {
                data["id"] = id
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(SharedStageModel.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
            complete(error)
        }
    }
}


