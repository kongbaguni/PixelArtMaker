//
//  LikeArtListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/13.
//

import SwiftUI
import FirebaseFirestore
import RealmSwift
import SDWebImageSwiftUI

struct LikeArtListView: View {
    let uid:String
    let gridItems:[GridItem]
    let itemSize:CGSize
    let isLimited:Bool
    
    @State var ids:[String] = []
    
    var collection: CollectionReference {
        Firestore.firestore().collection("pixelarts").document(uid).collection("like")
    }
    
    func getListFromFirebase(complete:@escaping(_ error:Error?)->Void) {
        func writeLocalDb(snapshot:QuerySnapshot?) {
            if let snapShot = snapshot {
                let realm = try! Realm()
                realm.beginWrite()
                for document in snapShot.documents {
                    var data = document.data()
                    if let did = data["id"] as? String {
                        data["id"] = "\(uid),\(did)"
                    }
                    realm.create(LikeModel.self, value: data, update: .all)
                }
                try! realm.commitWrite()
            }
        }
        var query = collection.order(by: "updateDt", descending: true)
        if let lastSync = try! Realm().objects(LikeModel.self).filter("uid = %@",uid).sorted(byKeyPath: "updateDt").last?.updateDt {
            query = query.whereField("updateDt", isGreaterThan: lastSync)
        }
        query = query.limit(to: Consts.profileImageLimit)
        query.getDocuments { snapshot, error in
            writeLocalDb(snapshot: snapshot)
            complete(error)
        }

    }

    private func loadFromLocalDb() {
        let result = try! Realm().objects(LikeModel.self).filter("uid = %@ && imageRefId != %@", uid, "").sorted(byKeyPath: "updateDt", ascending: false).map({ model in
            return model.id
        })
        if isLimited {
            let limit = Consts.profileImageLimit
            var new:[String] = []
            for i in 0..<limit {
                if i < result.count {
                    new.append(result[i])
                }
            }
            ids = new
        } else {
            ids = result.reversed().reversed()
        }
    }
    
    private func getModel(id:String)->LikeModel? {
        return try! Realm().object(ofType: LikeModel.self, forPrimaryKey: id)
    }
    
    private func makeLikeView(id:String)-> some View {
        VStack {        
            if let model = getModel(id: id) {
                NavigationLink {
                    PixelArtDetailView(id: model.documentId, showProfile: true)
                } label: {
                    if itemSize.width > 0 && itemSize.height > 0 {
                        FSImageView(imageRefId: model.imageRefId, placeholder: .imagePlaceHolder)
                            .frame(width: itemSize.width, height: itemSize.height, alignment: .center)
                    }
                }
            }
        }
        
    }
    

    var body: some View {
        Group {
            if ids.count > 0 {
                LazyVGrid(columns: gridItems, spacing:20) {
                    ForEach(ids, id:\.self) { id in
                        makeLikeView(id: id)
                            .onAppear {
                                if isLimited == false {
                                    if id == ids.last {
                                        if ids.count > 0 && ids.count % Consts.profileImageLimit == 0 {
                                            getListFromFirebase { error in
                                                loadFromLocalDb()
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Text("empty like list message")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }.onAppear {
            loadFromLocalDb()
            getListFromFirebase { error in
                loadFromLocalDb()
            }
        }
    }
}





struct LikeArtListFullView: View {
    
    let uid:String
    var body: some View {
        GeometryReader { geomentry in
            ScrollView {
                if geomentry.size.width < geomentry.size.height {
                    LikeArtListView(uid: uid, gridItems: Utill.makeGridItems(length: 3, screenWidth: geomentry.size.width),
                                    itemSize: Utill.makeItemSize(length: 3, screenWidth: geomentry.size.width), isLimited: false)
                }
                else {
                    LikeArtListView(uid: uid, gridItems: Utill.makeGridItems(length: 5, screenWidth: geomentry.size.width),
                                    itemSize: Utill.makeItemSize(length: 5, screenWidth: geomentry.size.width), isLimited: false)

                }
                
            }
        }
    }
}
