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
        let imageURL:URL
        let regDt:Date
        let updateDt:Date
        let likeCount:Int
        let isMyLike:Bool
    }
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var documentId:String = ""
    @Persisted var uid:String = ""
    @Persisted var email:String = ""
    @Persisted var imageUrl:String = ""
    @Persisted var regDt:TimeInterval = 0.0
    @Persisted var updateDt:TimeInterval = 0.0
    @Persisted var deleted:Bool = false
    @Persisted var likeUids:String = ""
    @Persisted var likeCount:Int = 0    
    
    var imageURLvalue:URL? {
        URL(string: imageUrl)
    }
    
    
    var regDate:Date {
        Date(timeIntervalSince1970: regDt)
    }
    
    var updateDate:Date {
        Date(timeIntervalSince1970: updateDt)
    }
    
    var isNew:Bool {
        Date().timeIntervalSince1970 - updateDt < 43200
    }
    
    var likeUserIdsSet:Set<String> {
        let arr = likeUids.components(separatedBy: ",")
        let set = Set<String>(arr)
        return set
    }
    
    var isMyLike:Bool {
        guard let uid = AuthManager.shared.userId else {
            return false
        }
        return likeUserIdsSet.firstIndex(of: uid) != nil
    }
    
    var threadSafeModel:ThreadSafeModel {
        .init(id: id,
              uid: uid,
              documentId: documentId,
              email: email,
              imageURL: URL(string: imageUrl)!,
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
        guard let collection = myLikeCollection else {
            complete(nil)
            return
        }
        let id = self.id
        let data:[String:Any] = [
            "id" : id,
            "imageURL" : imageUrl
        ]
        
        collection.whereField("id", isEqualTo: self.id).getDocuments { snapshot, error in
            if let err = error {
                complete(err)
                return
            }
                
            if snapshot?.documents.count ?? 0 > 0 {
                //좋아요 있다
                if isLike {
                    complete(nil)
                    return
                } // 있으니까 지운다. (좋아요 취소함)
                collection.document(id).delete { error in
                    complete(error)
                }

            } else {
                //좋아요 없다
                if isLike == false {
                    complete(nil)
                    return
                } // 없으니까 만든다 (좋아요 추가함)
                collection.document(id).setData(data) { error in
                    complete(error)
                }
            }
        }
        
    }
    
    func likeToggle(complete:@escaping(_ isLike:Bool, _ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            return
        }
        if id.isEmpty {
            return
        }
        let id = self.id
        collection.document(id).getDocument { snapShot, error in
            if var data = snapShot?.data() {
                data["id"] = id

                let realm = try! Realm()
                realm.beginWrite()
                let model = realm.create(SharedStageModel.self, value: data, update: .modified)
                try! realm.commitWrite()
                var result = false
                var likeSet:Set<String> = model.likeUserIdsSet
                if model.isMyLike {
                    likeSet.remove(uid)
                    result = false
                } else {
                    likeSet.insert(uid)
                    result = true
                }
                
                let updateData:[String:AnyHashable] = [
                    "id":id,
                    "likeUids" : likeSet.sorted().joined(separator: ","),
                    "likeCount" : likeSet.filter({ str in
                        return str.isEmpty == false
                    }).count
                ]
                
                realm.beginWrite()
                realm.create(SharedStageModel.self, value: updateData, update: .modified)
                try! realm.commitWrite()
                
                collection.document(id).updateData(updateData) { errorA in
                    self.updateMyLikeList(isLike: result) { errorB in
                        complete(result ,errorA ?? errorB)
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
