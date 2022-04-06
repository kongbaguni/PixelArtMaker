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


class FirebaseStorageHelper {
    static let shared = FirebaseStorageHelper()
    
    let storageRef = Storage.storage().reference()
    enum ContentType:String {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }
    
    func uploadImage(url:URL, contentType:ContentType, uploadURL:String, complete:@escaping(_ downloadURL:URL?, _ error:Error?)->Void) {
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

        uploadData(data: data, contentType: contentType, uploadURL: uploadURL, complete: complete)
    }

    
    func uploadData(data:Data, contentType:ContentType, uploadURL:String, complete:@escaping(_ downloadURL:URL?, _ error:Error?)->Void) {
        let ref:StorageReference = storageRef.child(uploadURL)
        let metadata = StorageMetadata()
        metadata.contentType = contentType.rawValue
        let task = ref.putData(data, metadata: metadata)
        task.observe(.success) { (snapshot) in
                    let path = snapshot.reference.fullPath
                    print(path)
                    ref.downloadURL { (downloadUrl, err) in
                        if (downloadUrl != nil) {
                            print(downloadUrl?.absoluteString ?? "없다")
                        }
                        complete(downloadUrl, nil)
                    }
                }
        task.observe(.failure) { snapshot in
            
            complete(nil, snapshot.error)
        }
    }
    
    func delete(deleteURL:String, complete:@escaping(_ error:Error?)->Void) {
        let ref = storageRef.child(deleteURL)
        ref.delete { error in
            complete(error)
        }
    }
}
