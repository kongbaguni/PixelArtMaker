//
//  StageManager.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/18.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import RealmSwift

class StageManager {
    let fireStore = Firestore.firestore()

    static let shared = StageManager() 
    var stage:StageModel? = nil  

    var stagePreviews:[StagePreviewModel] {
        let realm = try! Realm()
        return realm.objects(StagePreviewModel.self).sorted(byKeyPath: "updateDt").reversed()
    }
    
    func initStage(size:CGSize) {
        let fc:Color? = stage?.forgroundColor
        let bc:Color? = stage?.backgroundColor
        let pc:[Color]? = stage?.paletteColors
        stage = StageModel(canvasSize: size)
        if let c = fc {
            stage?.forgroundColor = c
        }
        if let c = bc {
            stage?.backgroundColor = c
        }
        if let c = pc {
            stage?.paletteColors = c
        }
    }
    
    var lastSaveTime:Date? = nil
    func saveTemp(comnplete:@escaping()->Void) {
        if let time = lastSaveTime {
            if Date().timeIntervalSince1970 - 2 < time.timeIntervalSince1970 {
                comnplete()
                return
            }
        }
        lastSaveTime = Date()

        DispatchQueue.global().async {[self] in
            let collection = fireStore.collection("temp")
            guard let stage = stage else {
                return
            }
                
            let str = stage.base64EncodedString
            
            let email = AuthManager.shared.auth.currentUser?.email ?? "guest"
            var data:[String:String] = [
                "data":str
            ]
            if let id = StageManager.shared.stage?.documentId {
                data["documentId"] = id
            }
            
            collection.document(email).setData(data, merge: true) { error in
                print(error?.localizedDescription ?? "성공")
                if error == nil {
                    DispatchQueue.main.async {
                        comnplete()
                    }
                }
            }

        }
    }
    
    func loadTemp(comptete:@escaping(_ isLoadSucess:Bool)->Void) {
        DispatchQueue.global().async {[self] in
            let collection = fireStore.collection("temp")
            let email = AuthManager.shared.auth.currentUser?.email ?? "guest"
            
            collection.document(email).getDocument { snapShopt, error in
                
                guard let data = snapShopt?.data(),
                      let string = data["data"] as? String,
                      let stage = StageModel.makeModel(base64EncodedString: string, documentId: nil)
                else {
                    comptete(false)
                    return
                }
                self.stage = stage
                if let id = data["documentId"] as? String {
                    self.stage?.documentId = id
                }
                            
                DispatchQueue.main.async {
                    comptete(true)
                }
            }
        }
    }
        
    func save(asNewForce:Bool,complete:@escaping()->Void) {
        if let time = lastSaveTime {
            if Date().timeIntervalSince1970 - 2 < time.timeIntervalSince1970 {
                complete()
                return
            }
        }
        lastSaveTime = Date()
        
        DispatchQueue.global().async {[self] in
            guard let email = AuthManager.shared.auth.currentUser?.email,
                  let stage = stage else {
                return
            }
            
            let collection = fireStore.collection("pixelarts").document(email).collection("data")
            var data:[String:AnyHashable] = [
                "data":stage.base64EncodedString,
                "updateDt":Date().timeIntervalSince1970
            ]
            if let preview = stage.makeImageDataValue(size: .init(width: 320, height: 320)) as? NSData,
                let cdata = try? preview.compressed(using: .zlib) {
                data["preview"] = cdata.base64EncodedString()
            }
            
            
            if let documentPath = self.stage?.documentId {
                if asNewForce == false {
                    let d = collection.document(documentPath)
                    d.updateData(data) {[self] error in
                        print(error?.localizedDescription ?? "업로드 성공")
                        loadList { result in
                            DispatchQueue.main.async {
                                complete()
                            }
                        }
                    }
                    return
                }
            }
            data["regDt"] = Date().timeIntervalSince1970
            collection.addDocument(data: data) {[self] error in
                print(error?.localizedDescription ?? "업로드 성공")
                loadList { result in
                    stage.documentId = try! Realm().objects(StagePreviewModel.self).sorted(byKeyPath: "updateDt").last?.documentId
                    DispatchQueue.main.async {
                        complete()
                    }
                }
            }
            
        }
    }
        
    func openStage(id:String, email:String? = nil, complete:@escaping(_ result:StageModel?)->Void) {
        guard let email = email ?? AuthManager.shared.auth.currentUser?.email else {
            complete(nil)
            return
        }

        DispatchQueue.global().async { [self] in
            let document = fireStore.collection("pixelarts").document(email).collection("data").document(id)
            document.getDocument { [self] snapShot, error in
                if let err = error {
                    print(err.localizedDescription)
                }
                guard let data = snapShot?.data(),
                      let str = data["data"] as? String
                else {
                    DispatchQueue.main.async {
                        complete(nil)
                    }
                    return
                }
                
                let model = StageModel.makeModel(base64EncodedString: str, documentId: id)
                stage = model
                DispatchQueue.main.async {
                    complete(model)
                }
            }
        
        }
    }
    
    func loadList(complete:@escaping(_ sucess:Bool)->Void) {
        let lastSync = StageManager.shared.stagePreviews.first?.updateDt
        
        func make(snapShot:QuerySnapshot?, error:Error?) {
            if let err = error {
                print(err.localizedDescription)
                complete(false)
                return
            }
            guard let datas = snapShot.map({ snap in
                return snap.documents.map { dsnap in
                    return (dsnap.data(), dsnap.documentID)
                }
            })
            else {
                return
            }
            let realm = try! Realm()
        
            var result:[StagePreviewModel] = []
            realm.beginWrite()

            for data in datas {
                if let string = data.0["preview"] as? String,
                   let updateInterval = data.0["updateDt"] as? TimeInterval,
                   let image = UIImage(base64encodedString: string) {
                    let updateDt = Date(timeIntervalSince1970: updateInterval)
                    var ddata:[String:AnyHashable] = [
                        "documentId":data.1,
                        "imageData":image.pngData(),
                        "updateDt":updateDt
                    ]
                    
                    if let sid = data.0["shared_document_id"] as? String {
                        ddata["shareDocumentId"] = sid
                    }
                    let model = realm.create(StagePreviewModel.self, value: ddata, update: .modified)
                    result.append(model)
                }
            }
            try! realm.commitWrite()
            
            result = result.sorted { a, b in
                return a.updateDt > b.updateDt
            }
                                    
            DispatchQueue.main.async {
                complete(true)
            }
        }
        DispatchQueue.global().async {[self] in
            guard let email = AuthManager.shared.auth.currentUser?.email else {
                return
            }
            let collection = fireStore.collection("pixelarts").document(email).collection("data")
            if let date = lastSync {
                collection
                    .whereField("updateDt", isGreaterThan: date.timeIntervalSince1970)
                    .getDocuments { snapShot, error in
                        make(snapShot: snapShot, error: error)
                    }
            } else {
                collection.getDocuments { snapShot, error in
                    make(snapShot: snapShot, error: error)
                }
            }
        }
    }
    
    func delete(documentId:String? = nil ,complete:@escaping(_ isSucess:Bool)->Void) {
        guard let id = documentId ?? stage?.documentId else {
            return
        }
        guard let email = AuthManager.shared.auth.currentUser?.email else {
            complete(false)
            return
        }
        
        DispatchQueue.global().async {[self] in
            let document = fireStore.collection("pixelarts").document(email).collection("data").document(id)
            document.delete { [self] error in
                if error == nil {
                    fireStore.collection("public").whereField("documentId", isEqualTo: id).getDocuments {[self] qs, error in
                        for doc in qs?.documents ?? [] {
                            let id = doc.documentID
                            fireStore.collection("public").document(id).updateData(["deleted":true, "updateDt":Date().timeIntervalSince1970]) { error in
                                
                            }
                        }
                        
                    }
                    
                    let realm = try! Realm()
                    if let model = realm.object(ofType: StagePreviewModel.self, forPrimaryKey: id) {
                        try! realm.write {
                            realm.delete(model)
                        }
                    }
                    deleteTemp { isSucess in
                        DispatchQueue.main.async {
                            complete(isSucess)
                        }
                    }
                    return
                }
                DispatchQueue.main.async {
                    complete(false)
                }
            }
        }        
    }
    
    func deleteTemp(complete:@escaping(_ isSucess:Bool)->Void) {
        guard let email = AuthManager.shared.auth.currentUser?.email else {
            return
        }
        let collection = fireStore.collection("temp")
        DispatchQueue.global().async {
            collection.document(email).delete { error in
                DispatchQueue.main.async {
                    complete(error == nil)
                }
            }
        }
    }
    
    func sharePublic(complete:@escaping(_ isSucess:Bool)->Void) {
        guard let id = stage?.documentId,
              let image = stage?.makeImageDataValue(size: .init(width: 320, height: 320)),
              let email = AuthManager.shared.auth.currentUser?.email
        else {
            return
        }
        let collection = fireStore.collection("public")
        let now = Date().timeIntervalSince1970
        var data:[String:AnyHashable] = [
            "documentId":id ,
            "image":image.base64EncodedString(),
            "email":email,
            "updateDt":now
        ]
        
        func getSharedList(complete:@escaping(_ list:[String])->Void) {
            collection.whereField("documentId", isEqualTo: id).getDocuments { snapShot, error in
                let ids = snapShot.map { snapShot in
                    snapShot.documents.map {dsnap in
                        return dsnap.documentID
                    }
                }
                complete(ids ?? [])
            }
        }
        func save(finish:@escaping(_ targetId:String?)->Void) {
            getSharedList { list in
                if list.count == 0 {
                    data["regDt"] = now
                    collection.addDocument(data: data) { error in
                        collection.whereField("documentId", isEqualTo: id).getDocuments { snapShot, error in
                            let ids = snapShot.map { snapShot in
                                snapShot.documents.map {dsnap in
                                    return dsnap.documentID
                                }
                            }
                            finish(ids?.first)
                        }
                    }
                }
                else {
                    collection.document(list.first!).updateData(data) { error in
                        finish(list.first!)
                    }
                }
            }
        }
        
        save(finish: {[self] shareId in
            let now = Date()
            let data:[String:AnyHashable] = [
                "shared_document_id":shareId!,
                "updateDt":now.timeIntervalSince1970
            ]
            fireStore.collection("pixelarts").document(email).collection("data").document(id).updateData(data) { error in
                let udata:[String:AnyHashable] = [
                    "documentId":id,
                    "shareDocumentId":shareId,
                    "updateDt":now
                ]
                let realm = try! Realm()
                try! realm.write {
                    realm.create(StagePreviewModel.self, value: udata, update: .modified)
                }
                complete(error == nil )
            }
        })
    }
    
    func loadSharedList(complete:@escaping()->Void){
        let collection = fireStore.collection("public")
        func make(snapShot:QuerySnapshot?, error:Error?) {
            let list = snapShot.map { qs in
                return qs.documents.map { qsn in
                    return (qsn.documentID,qsn.data())
                }
            }
            let realm = try! Realm()
            realm.beginWrite()
            for item in list ?? [] {
                var data = item.1
                data["id"] = item.0
                realm.create(SharedStageModel.self, value: data, update: .modified)
            }
            print("new item \(list?.count ?? 0)")
            try! realm.commitWrite()
            complete()
        }
        
        let lastSyncDt = try! Realm().objects(SharedStageModel.self).sorted(byKeyPath: "updateDt").last?.updateDt
        if let dt = lastSyncDt {
            collection.whereField("updateDt", isGreaterThan: dt).getDocuments { snapShot, error in
                make(snapShot: snapShot, error: error)
            }
        }
        else {
            collection.getDocuments { snapShot, error in
                make(snapShot: snapShot, error: error)
            }
        }
    }
}
