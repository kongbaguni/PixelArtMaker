//
//  FirebaseStorageHelper.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import RealmSwift

class FirebaseStorageHelper {
    static let shared = FirebaseStorageHelper()
    
    let storageRef = Storage.storage().reference()
    enum ContentType:String {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }
    
    func uploadImage(url:URL, contentType:ContentType, uploadPath:String, id:String, complete:@escaping(_ downloadURL:URL?, _ error:Error?)->Void) {
        guard var data = try? Data(contentsOf: url) else {
            complete(nil, nil)
            return
        }
        switch contentType {
        case .png:
            if let pngData = UIImage(data: data)?.pngData() {
                data = pngData
            }

        case .jpeg:
            if let jpgData = UIImage(data: data)?.jpegData(compressionQuality: 0.7) {
                data = jpgData
            }
        }

        uploadData(data: data, contentType: contentType, uploadPath: uploadPath, id: id, complete: complete)
    }

    
    func uploadData(data:Data, contentType:ContentType, uploadPath:String = Consts.imageUploadPath, id:String, complete:@escaping(_ downloadURL:URL?, _ error:Error?)->Void) {
        let ref:StorageReference = storageRef.child("\(uploadPath)/\(id)")
        let metadata = StorageMetadata()
        metadata.contentType = contentType.rawValue
        let task = ref.putData(data, metadata: metadata)
        task.observe(.success) { (snapshot) in
            let path = snapshot.reference.fullPath
            print(snapshot.reference.name)
            print(path)
            
            ref.downloadURL { (downloadUrl, err) in
                if let url = downloadUrl {
                    print(url)
                }
                complete(downloadUrl, nil)
            }
        }
        task.observe(.failure) { snapshot in
            complete(nil, snapshot.error)
        }
    }
        
    func getDownloadURL(uploadPath:String = Consts.imageUploadPath, id:String,complete:@escaping(_ url:URL?, _ error:Error?)->Void) {
        let realm = try! Realm()
        if let model = realm.object(ofType: FirebaseStorageImageUrlCashModel.self, forPrimaryKey: id) {
            if model.isExpire == false {
                complete(URL(string: model.url), nil)
                return
            }
        }
        let ref:StorageReference = storageRef.child("\(uploadPath)/\(id)")
        ref.downloadURL { downloadURL, err in
            if let url = downloadURL {
                let realm = try! Realm()
                let data:[String:AnyHashable] = [
                    "id":id,
                    "url":url.absoluteString,
                    "date":Date()
                ]
                try! realm.write {
                    realm.create(FirebaseStorageImageUrlCashModel.self, value: data, update: .all)
                }
            }
            complete(downloadURL,err)
        }
    }
    
    func delete(deleteURL:String, complete:@escaping(_ error:Error?)->Void) {
        let ref = storageRef.child(deleteURL)
        ref.delete { error in
            complete(error)
        }
    }
}


