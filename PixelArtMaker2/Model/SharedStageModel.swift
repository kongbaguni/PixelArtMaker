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
        let regDt:Date
        let updateDt:Date
        let likeCount:Int
        let isNSFW:Bool
    }
    
    @Persisted(primaryKey: true) var id:String = ""
    /** 원본의 아이디 불러오기 구현시 참조용.*/
    @Persisted var documentId:String = ""
    @Persisted var uid:String = ""
    @Persisted var regDt:TimeInterval = 0.0
    @Persisted var updateDt:TimeInterval = 0.0
    @Persisted var deleted:Bool = false
    @Persisted var likeCount:Int = 0
    @Persisted var isNSFW:Bool = false
    
    var regDate:Date {
        Date(timeIntervalSince1970: regDt)
    }
    
    var updateDate:Date {
        Date(timeIntervalSince1970: updateDt)
    }
    
    var isNew:Bool {
        Date().timeIntervalSince1970 - updateDt < 43200
    }
            
    var threadSafeModel:ThreadSafeModel {
        .init(id: id,
              uid: uid,
              documentId: documentId,
              regDt: Date(timeIntervalSince1970: regDt),
              updateDt: Date(timeIntervalSince1970: updateDt),
              likeCount: likeCount,
              isNSFW : isNSFW
        )
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
    
    
    static func findBy(id:String,complete:@escaping(_ isDeleted:Bool, _ error:Error?)->Void) {
        collection.document(id).getDocument { snapShot, error in
            if var data = snapShot?.data() {
                data["id"] = id
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(SharedStageModel.self, value: data, update: .modified)
                try! realm.commitWrite()
                complete(false, error)
                return
            }
            complete(true,error)
        }
    }
    
    static func findBy(id:String)->SharedStageModel? {
        return try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id)
    }
}


