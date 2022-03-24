//
//  StageManager.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/18.
//

import Foundation
import SwiftUI
import FirebaseFirestore


class StageManager {
    let fireStore = Firestore.firestore()

    static let shared = StageManager() 
    var stage:StageModel? = nil  

    var stagePreviews:[StagePreviewModel] = []
    
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
        
        DispatchQueue.global().async {[self] in
            guard let email = AuthManager.shared.auth.currentUser?.email,
                  let stage = stage else {
                return
            }
            
            let collection = fireStore.collection("pixelarts")
            
            let data = [
                "data":stage.base64EncodedString
            ]
            
            if let documentPath = self.stage?.documentId {
                if asNewForce == false {
                    let d = collection.document(email).collection("data").document(documentPath)
                    d.setData(data) { error in
                        print(error?.localizedDescription ?? "업로드 성공")
                        DispatchQueue.main.async {
                            complete()
                        }
                    }
                    return
                }
            }
            collection.document(email).collection("data").addDocument(data: data) { error in
                print(error?.localizedDescription ?? "업로드 성공")
                DispatchQueue.main.async {
                    complete()
                }
            }
            
        }
    }
        
    func openStage(id:String, complete:@escaping(_ result:StageModel?)->Void) {
        guard let email = AuthManager.shared.auth.currentUser?.email else {
            complete(nil)
            return
        }

        DispatchQueue.global().async {[self] in
            let document = fireStore.collection("pixelarts").document(email).collection("data").document(id)
            document.getDocument { snapShot, error in
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
                DispatchQueue.main.async {
                    complete(model)
                }
            }
        
        }
    }
    func loadList(complete:@escaping(_ result:[StagePreviewModel])->Void) {
        DispatchQueue.global().async {[self] in
            guard let email = AuthManager.shared.auth.currentUser?.email else {
                return
            }
            let collection = fireStore.collection("pixelarts").document(email).collection("data")
            collection.getDocuments { snapShot, error in
                if let err = error {
                    print(err.localizedDescription)
                }
                guard let datas = snapShot.map({ snap in
                    return snap.documents.map { dsnap in
                        return (dsnap.data(), dsnap.documentID)
                    }
                })
                else {
                    return
                }
                
                
                var result:[StagePreviewModel] = []
                for data in datas {
                    if let string = data.0["data"] as? String,
                       let image = StageModel.getPreview(base64EncodedString: string) {
                        let model = StagePreviewModel.init(documentId: data.1, image: image)
                        result.append(model)
                    }
                }
                DispatchQueue.main.async {
                    self.stagePreviews = result
                    complete(result)
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
            document.delete { error in
                DispatchQueue.main.async {
                    complete(error == nil)
                }
            }
        }        
    }
    
}
