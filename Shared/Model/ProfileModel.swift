//
//  ProfileModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/02.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class ProfileModel: Object {
    @Persisted(primaryKey: true) var uid:String = ""
    @Persisted var nickname:String = ""
    @Persisted var profileURL:String = ""
    @Persisted var email:String = ""
}

fileprivate let collection = Firestore.firestore().collection("profile")
fileprivate func createDefaultProfile(complete:@escaping(_ isSucess:Bool)->Void) {
    guard let uid = AuthManager.shared.userId else {
        complete(false)
        return
    }
    let data:[String:String] = [
        "uid":uid,
        "email":AuthManager.shared.auth.currentUser?.email ?? "",
        "nickname":AuthManager.shared.auth.currentUser?.displayName ?? AuthManager.shared.auth.currentUser?.email ?? "",
        "profileURL":AuthManager.shared.auth.currentUser?.photoURL?.absoluteString ?? ""
    ]
    collection.document(uid).setData(data) { error in
        print(error?.localizedDescription ?? "성공")
        complete(error == nil)
    }
}

extension ProfileModel {
    var profileImageURL:URL? {
        return URL(string: profileURL)
    }
    
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
                complete(error)
            }
        }
    }
    
    static var currentUser:ProfileModel? {
        if let uid = AuthManager.shared.userId {
            return try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid)
        }
        return nil
    }
    
    static func downloadProfile(complete:@escaping(_ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }
        
        collection.document(uid).getDocument { snapShot, error in
            if error == nil && snapShot?.data() == nil {
                createDefaultProfile { isSucess in
                    downloadProfile(complete: complete)
                }
                return
            }
            if let data = snapShot?.data() {
                let realm = try! Realm()
                try! realm.write {
                    realm.create(ProfileModel.self, value: data, update: .all)
                }
                complete(error)
                return
            }
            complete(error)
        }
    }
    
    func updateProfile(complete:@escaping(_ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }
        let data:[String:String] = [
            "uid":uid,
            "nickname":nickname,
            "profileURL":profileURL,
            "email":email
        ]
        collection.document(uid).updateData(data) { error in
            if let err = error {
                print(err.localizedDescription)
            }
            complete(error)
        }
    }
}
