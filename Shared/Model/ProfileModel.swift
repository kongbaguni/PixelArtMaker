//
//  ProfileModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/02.
//

import Foundation
import RealmSwift
import FirebaseFirestore

extension Notification.Name {
    static let profileDidUpdated = Notification.Name("profileDidUpdated_observer")
}

class ProfileModel: Object {
    @Persisted(primaryKey: true) var uid:String = ""
    @Persisted var nickname:String = ""
    @Persisted var profileImageRefId:String = ""
    @Persisted var email:String = ""
    @Persisted var introduce:String = ""
    @Persisted var updateDt:TimeInterval = 0
}

fileprivate let collection = Firestore.firestore().collection("profile")
fileprivate func createDefaultProfile(complete:@escaping(_ isSucess:Bool)->Void) {
    guard let uid = AuthManager.shared.userId else {
        complete(false)
        return
    }
    let data:[String:AnyHashable] = [
        "uid":uid,
        "email":AuthManager.shared.auth.currentUser?.email ?? "",
        "nickname":AuthManager.shared.auth.currentUser?.displayName ?? AuthManager.shared.auth.currentUser?.email ?? "",
        "profileURL":AuthManager.shared.auth.currentUser?.photoURL?.absoluteString ?? "",
        "updateDt":Date().timeIntervalSince1970
    ]
    collection.document(uid).setData(data) { error in
        print(error?.localizedDescription ?? "성공")
        complete(error == nil)
    }
}

extension ProfileModel {
    static func findBy(uid:String)->ProfileModel? {
        return try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid)
    }
    
    static func findBy(uid:String, complete:@escaping(_ error:Error?)->Void) {
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
    
    static var currentUser:ProfileModel? {
        if let uid = AuthManager.shared.userId {
            return try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid)
        }
        return nil
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
            collection.document(uid).getDocument { snapShot, error in
                if error == nil && snapShot?.data() == nil && isCreateDefaultProfile {
                    createDefaultProfile { isSucess in
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
    
    func updateProfile(complete:@escaping(_ error:Error?)->Void) {
        ProfileModel.updateProfile(nickname: nickname, introduce: introduce, profileImageRefId: profileImageRefId, email: email, complete: complete)
    }
    
    
    static func updateProfile(nickname:String, introduce:String? = nil, profileImageRefId:String? = nil, email:String? = nil, complete:@escaping(_ error:Error?)->Void) {
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
    
    func updatePhoto(photoRefId:String, complete:@escaping(_ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }

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
