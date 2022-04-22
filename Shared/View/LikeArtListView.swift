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
    let limit:Int
    
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
        
        if let lastSync = try! Realm().objects(LikeModel.self).filter("uid = %@",uid).sorted(byKeyPath: "updateDt").last?.updateDt {
            collection.whereField("updateDt", isGreaterThan: lastSync).getDocuments { snapshot, error in
                writeLocalDb(snapshot: snapshot)
                complete(error)
            }
        } else {
            collection.getDocuments { snapshot, error in
                writeLocalDb(snapshot: snapshot)
                complete(error)
            }
        }
    }

    private func loadFromLocalDb() {
        let result = try! Realm().objects(LikeModel.self).filter("uid = %@ && imageRefId != %@", uid, "").sorted(byKeyPath: "updateDt", ascending: true).map({ model in
            return model.id
        })
        ids = result.reversed()
        if limit > 0 && ids.count > limit {
            var new:[String] = []
            for i in 0..<limit {
                new.append(ids[i])
            }
            ids = new
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
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Text("empty like list message")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(30)
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
                                    itemSize: Utill.makeItemSize(length: 3, screenWidth: geomentry.size.width), limit: 0)
                }
                else {
                    LikeArtListView(uid: uid, gridItems: Utill.makeGridItems(length: 5, screenWidth: geomentry.size.width),
                                    itemSize: Utill.makeItemSize(length: 5, screenWidth: geomentry.size.width), limit: 0)

                }
                
            }
        }
    }
}
