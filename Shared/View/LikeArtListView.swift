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

    @State var ids:[String] = []
    
    var collection: CollectionReference {
        Firestore.firestore().collection("pixelarts").document(uid).collection("like")
    }
    
    func getListFromFirebase(complete:@escaping(_ error:Error?)->Void) {
        collection.getDocuments { snapshot, error in
            if let snapShot = snapshot {
                let realm = try! Realm()
                realm.beginWrite()
                for document in snapShot.documents {
                    var data = document.data()
                    print(data)
                    if let did = data["id"] as? String {
                        data["id"] = "\(uid),\(did)"
                    }
                    realm.create(LikeModel.self, value: data, update: .all)
                }
                try! realm.commitWrite()
            }
            complete(error)
        }
    }

    private func loadFromLocalDb() {
        let result = try! Realm().objects(LikeModel.self).filter("uid = %@", uid).sorted(byKeyPath: "updateDt", ascending: false).map({ model in
            return model.id
        })
        ids = result.reversed()
        print(ids)
        
    }
    
    private func getModel(id:String)->LikeModel {
        return try! Realm().object(ofType: LikeModel.self, forPrimaryKey: id)!
    }
    
    private func makeLikeView(id:String)-> some View {
        VStack {        
            NavigationLink {
                PixelArtDetailView(id: getModel(id: id).documentId, showProfile: true)
            } label: {
                if let url = URL(string: getModel(id: id).imageURL) {
                    if itemSize.width > 0 && itemSize.height > 0 {
                        WebImage(url:url)
                            .resizable()
                            .frame(width: itemSize.width, height: itemSize.height, alignment: .center)
                    }
                }
            }
        }
        
    }
    

    var body: some View {
        LazyVGrid(columns: gridItems, spacing:20) {
            ForEach(ids, id:\.self) { id in
                makeLikeView(id: id)
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
                    LikeArtListView(uid: uid, gridItems: makeGridItems(length: 3, screenWidth: geomentry.size.width),
                                    itemSize: makeItemSize(length: 3, screenWidth: geomentry.size.width))
                }
                else {
                    LikeArtListView(uid: uid, gridItems: makeGridItems(length: 5, screenWidth: geomentry.size.width),
                                    itemSize: makeItemSize(length: 5, screenWidth: geomentry.size.width))

                }
                
            }
        }
    }
}
