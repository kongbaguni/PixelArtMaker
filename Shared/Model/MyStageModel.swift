//
//  MyStageModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/24.
//

import Foundation
import UIKit
import RealmSwift

class MyStageModel : Object {
    @Persisted(primaryKey: true) var documentId:String = ""
    @Persisted var imageURL:String = ""
    @Persisted var updateDt:Date = Date()
    @Persisted var shareDocumentId:String = ""
    
    
    struct ThreadSafeModel : Hashable {
        public static func == (lhs: ThreadSafeModel, rhs: ThreadSafeModel) -> Bool {
            return lhs.documentId == rhs.documentId
        }
        let documentId:String
        let imageURL:URL?
        let updateDt:Date
        let shareDocumentId:String
    }
    
    var threadSafeModel:ThreadSafeModel {
        return .init(documentId: documentId, imageURL: URL(string: imageURL), updateDt: updateDt, shareDocumentId: shareDocumentId)
    }
}


