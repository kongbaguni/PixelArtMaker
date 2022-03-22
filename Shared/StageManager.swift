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
    
    func saveTemp(comnplete:@escaping()->Void) {
        let collection = fireStore.collection("temp")
        guard let stage = stage else {
            return
        }
            
        let str = stage.base64EncodedString
        
        let email = AuthManager.shared.auth.currentUser?.email ?? "guest"
        let data:[String:String] = [
            "title":stage.title ?? "",
            "email":AuthManager.shared.auth.currentUser?.email ?? "guest",
            "data":str
        ]
        
        collection.document(email).setData(data, merge: true) { error in
            print(error?.localizedDescription ?? "성공")
            if error == nil {
                comnplete()
            }
        }
    }
    
    func loadTemp(comptete:@escaping()->Void) {
        let collection = fireStore.collection("temp")
        let email = AuthManager.shared.auth.currentUser?.email ?? "guest"

        collection.document(email).getDocument { snapShopt, error in
            guard let data = snapShopt?.data(),
                  let string = data["data"] as? String,
                  let stage = StageModel.makeModel(base64EncodedString: string)
            else {
                return
            }
            
            self.stage = stage
            comptete()
        }
    }
}
