//
//  TimeLineManager.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/27.
//

import Foundation
import FirebaseFirestore
import RealmSwift

struct TimeLineManager {
    let collection = Firestore.firestore()
        .collection("public")
//        .order(by: "deleted")
//        .whereField("deleted", isNotEqualTo: true)
    
    func getTimeLine(order:Sort.SortType, lastDt:TimeInterval?, limit:Int, complete:@escaping(_ resultIds:[String], _ error:Error?)->Void) {
        var query:FirebaseFirestore.Query? = nil
        switch order {
        case .latestOrder:
            query = collection.order(by: "updateDt", descending: true)
            if let interval = lastDt {
                query = query?.whereField("updateDt", isLessThan: interval)
            }
        case .oldnet:
            query = collection.order(by: "updateDt", descending: false)
            if let interval = lastDt {
                query = query?.whereField("updateDt", isGreaterThan: interval)
            }
        case .like:
            query = collection.order(by: "likeCount", descending: true)
        }
        if limit > 0 {
            query = query?.limit(to: limit)
        }
        query?.getDocuments(completion: { snapShot, error in
            if let list = snapShot?.documents {
                complete  (
                    list.map { snapShot in
                        return writeDb(snapshot: snapShot)
                    },
                    error
                )
            } else {
                complete([], error)
            }
        })
    }
    
    private func writeDb(snapshot:QueryDocumentSnapshot)->String {        
        let parm = snapshot.data()
        if parm["id"] as? String != nil {
            let realm = try! Realm()
            realm.beginWrite()
            realm.create(SharedStageModelForTimeLine.self, value: parm, update: .all)
            try! realm.commitWrite()
        }
        return parm["id"] as? String ?? ""
    }
    
    func loadFromLocalDB()->[String] {
        let realm = try! Realm()
        let list = realm.objects(SharedStageModelForTimeLine.self)
            .sorted(byKeyPath: "updateDt", ascending: false)
            .filter("deleted != %@", true)
        var result:[String] = []
        for model in list {
            result.append(model.id)
        }
        return result
    }
}
