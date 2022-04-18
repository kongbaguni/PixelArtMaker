//
//  ReplyManager.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/18.
//

import Foundation
import FirebaseFirestore

class ReplyManager {
    static let shared = ReplyManager()
    
    let collection = Firestore.firestore().collection("reply")

    func addReply(replyModel:ReplyModel,complete:@escaping(_ error:Error?)->Void) {
        guard let data = replyModel.jsonValue else {
            return
        }
        
        collection.document(replyModel.id).setData(data) { error in
            complete(error)
        }
    }
    
    func getReplys(documentId:String, complete:@escaping(_ result:[ReplyModel], _ error:Error?)->Void) {
        collection.whereField("documentId", isEqualTo: documentId)
            .getDocuments { snapShot, error in
                var result:[ReplyModel] = []

                if let documents = snapShot?.documents {
                    for doc in documents {
                        let json = doc.data() as [String:AnyObject]
                        if let model = ReplyModel.makeModel(json: json)  {
                            result.append(model)
                        }
                        
                    }
                }
                complete(result.reversed(),error)
            }
    }
    
    func deleteReply(id:String, complete:@escaping(_ error:Error?)->Void) {
        collection.document(id).delete { error in
            complete(error)
        }
    }
}
