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


extension ProfileModel {
    static func findBy(uid:String)->ProfileModel? {
        return try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid)
    }
        
    static var currentUser:ProfileModel? {
        if let uid = AuthManager.shared.userId {
            return try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid)
        }
        return nil
    }
    
    func updateProfile(complete:@escaping(_ error:Error?)->Void) {
        FirestoreHelper.Profile.updateProfile(nickname: nickname, introduce: introduce, profileImageRefId: profileImageRefId, email: email, complete: complete)
    }
    
    
   
    
}
