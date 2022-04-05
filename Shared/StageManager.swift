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

    var stagePreviews:Results<MyStageModel> {
        let realm = try! Realm()
        return realm.objects(MyStageModel.self)//.sorted(byKeyPath: "updateDt").reversed()
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
    
    var lastSaveTempTime:Date? = nil
    func saveTemp(documentId:String? = nil ,complete:@escaping(_ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }
        if let time = lastSaveTempTime {
            if Date().timeIntervalSince1970 - 2 < time.timeIntervalSince1970 {
                complete(nil)
                return
            }
        }
        lastSaveTempTime = Date()

        DispatchQueue.global().async {[self] in
            let collection = fireStore.collection("temp")
            guard let stage = stage else {
                return
            }
                
            let str = stage.base64EncodedString
            
            var data:[String:String] = [
                "data":str
            ]
            if let id = documentId ?? StageManager.shared.stage?.documentId {
                data["documentId"] = id
            }
            
            collection.document(uid).setData(data, merge: true) { error in
                print(error?.localizedDescription ?? "성공")
                if error == nil {
                    DispatchQueue.main.async {
                        complete(error)
                    }
                }
            }

        }
    }
    
    func loadTemp(complete:@escaping(_ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }
        DispatchQueue.global().async {[self] in
            let collection = fireStore.collection("temp")
            
            
            collection.document(uid).getDocument { snapShopt, error in
                
                guard let data = snapShopt?.data(),
                      let string = data["data"] as? String,
                      let stage = StageModel.makeModel(base64EncodedString: string, documentId: nil)
                else {
                    DispatchQueue.main.async {
                        complete(error)
                    }
                    return
                }
                self.stage = stage
                self.stage?.createrId = uid
                if let id = data["documentId"] as? String {
                    self.stage?.documentId = id
                }
                            
                DispatchQueue.main.async {
                    complete(error)
                }
            }
        }
    }
        
    var lastSaveTime:Date? = nil
    func save(asNewForce:Bool,complete:@escaping(_ error:Error?)->Void) {
        if let time = lastSaveTime {
            if Date().timeIntervalSince1970 - 2 < time.timeIntervalSince1970 {
                complete(nil)
                return
            }
        }
        lastSaveTime = Date()
        
        
        DispatchQueue.global().async {[self] in
            guard let uid = AuthManager.shared.userId,
                  let stage = stage else {
                DispatchQueue.main.async {
                    complete(nil)
                }
                return
            }
            
            let collection = fireStore.collection("pixelarts").document(uid).collection("data")
            var data:[String:AnyHashable] = [
                "data":stage.base64EncodedString,
                "updateDt":Date().timeIntervalSince1970
            ]
            if let preview = stage.makeImageDataValue(size: Consts.previewImageSize) as? NSData,
                let cdata = try? preview.compressed(using: .zlib) {
                data["preview"] = cdata.base64EncodedString()
            }
            
            
            if let documentPath = self.stage?.documentId {
                if asNewForce == false {
                    let d = collection.document(documentPath)
                    d.updateData(data) {[self] error in
                        print(error?.localizedDescription ?? "업로드 성공")
                        loadList { [self] result in
                            saveTemp (documentId: documentPath, complete: { tmpError in
                                DispatchQueue.main.async {
                                    complete(error)
                                }
                            })
                        }
                    }
                    return
                }
            }
            data["regDt"] = Date().timeIntervalSince1970
            collection.addDocument(data: data) {[self] error in
                print(error?.localizedDescription ?? "업로드 성공")
                loadList { [self] result in
                    stage.documentId = try! Realm().objects(MyStageModel.self).sorted(byKeyPath: "updateDt").last?.documentId
                    
                    saveTemp(documentId: stage.documentId, complete: { tmeError in
                        DispatchQueue.main.async {
                            complete(error)
                        }
                    })
                    
                }
            }
            
        }
    }
        
    func openStage(id:String, uid:String? = nil, complete:@escaping(_ result:StageModel?, _ error:Error?)->Void) {
        guard let uid = uid ?? AuthManager.shared.userId else {
            complete(nil,nil)
            return
        }
        if uid.isEmpty {
            complete(nil,nil)
            return
        }

        DispatchQueue.global().async { [self] in
            let document = fireStore.collection("pixelarts").document(uid).collection("data").document(id)
            document.getDocument { [self] snapShot, error in
                if let err = error {
                    print(err.localizedDescription)
                }
                guard let data = snapShot?.data(),
                      let str = data["data"] as? String
                else {
                    DispatchQueue.main.async {
                        complete(nil,error)
                    }
                    return
                }
                
                let model = StageModel.makeModel(base64EncodedString: str, documentId: id)
                stage = model
                model?.createrId = uid
                DispatchQueue.main.async {
                    complete(model,error)
                }
            }
        
        }
    }
    
    func loadList(complete:@escaping(_ error:Error?)->Void) {
        
        
        func make(snapShot:QuerySnapshot?, error:Error?) {
            if let err = error {
                DispatchQueue.main.async {
                    complete(err)
                }
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
        
            var result:[MyStageModel] = []
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
                    let model = realm.create(MyStageModel.self, value: ddata, update: .modified)
                    result.append(model)
                }
            }
            try! realm.commitWrite()
            
            result = result.sorted { a, b in
                return a.updateDt > b.updateDt
            }
                                    
            DispatchQueue.main.async {
                complete(nil)
            }
        }
        DispatchQueue.global().async {[self] in
            let lastSync = StageManager.shared.stagePreviews.first?.updateDt
            
            guard let uid = AuthManager.shared.userId else {
                return
            }
            let collection = fireStore.collection("pixelarts").document(uid).collection("data")
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
    
    func delete(documentId:String? = nil ,complete:@escaping(_ error:Error?)->Void) {
        guard let id = documentId ?? stage?.documentId else {
            return
        }
        guard let uid = AuthManager.shared.userId else {
            complete(nil)
            return
        }
        
        DispatchQueue.global().async {[self] in
            let document = fireStore.collection("pixelarts").document(uid).collection("data").document(id)
            document.delete { [self] error in
                if error == nil {
                    fireStore.collection("public").whereField("documentId", isEqualTo: id).getDocuments {[self] qs, error in
                        for doc in qs?.documents ?? [] {
                            let id = doc.documentID
                            let updateData:[String:AnyHashable] = [
                                "email":"",
                                "documentId":"",
                                "image":"",
                                "deleted":true,
                                "updateDt":Date().timeIntervalSince1970
                            ]
                            fireStore.collection("public").document(id).updateData(updateData) { error in
                                
                            }
                        }
                        
                    }
                    
                    let realm = try! Realm()
                    if let model = realm.object(ofType: MyStageModel.self, forPrimaryKey: id) {
                        try! realm.write {
                            realm.delete(model)
                        }
                    }
                    deleteTemp { isSucess in
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
    
    func deleteTemp(complete:@escaping(_ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            return
        }
        let collection = fireStore.collection("temp")
        DispatchQueue.global().async {
            collection.document(uid).delete { error in
                DispatchQueue.main.async {
                    complete(error)
                }
            }
        }
    }
    
    func sharePublic(complete:@escaping(_ error:Error?)->Void) {
        guard let id = stage?.documentId,
              let image = stage?.makeImageDataValue(size: Consts.previewImageSize),
              let uid = AuthManager.shared.userId,
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
            "updateDt":now,
            "uid":uid
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
            fireStore.collection("pixelarts").document(uid).collection("data").document(id).updateData(data) { error in
                let udata:[String:AnyHashable] = [
                    "documentId":id,
                    "shareDocumentId":shareId,
                    "updateDt":now
                ]
                let realm = try! Realm()
                try! realm.write {
                    realm.create(MyStageModel.self, value: udata, update: .modified)
                }
                complete(error)
            }
        })
    }
    
    func loadSharedList(sort:Sort.SortType, limit:Int = 50, complete:@escaping(_ error:Error?)->Void){
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
                print(data["likeCount"] as? String ?? "")
                realm.create(SharedStageModel.self, value: data, update: .modified)
            }
            print("new item \(list?.count ?? 0)")
            try! realm.commitWrite()
            complete(error)
        }
                
        var sortvalue:(String,Bool) {
            switch sort {
            case .oldnet:
                return ("updateDt",false)
            case .latestOrder:
                return ("updateDt", true)
            case .like:
                return ("likeCount", true)
            }
        }
         
        
        let orderd = collection
            .order(by: sortvalue.0, descending: sortvalue.1)
        
        orderd.limit(to: limit).getDocuments { snapShot, error in
            make(snapShot: snapShot, error: error)
        }
    }
    
    
    
}
