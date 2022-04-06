//
//  ArtListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/06.
//

import SwiftUI
import FirebaseFirestore
import RealmSwift
import SDWebImageSwiftUI
fileprivate let width1 = screenBounds.width - 10
fileprivate let width2 = screenBounds.width / 2 - 10
fileprivate let width3 = screenBounds.width / 3 - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50

struct ArtListView: View {
    let collection = Firestore.firestore().collection("public")
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var ids:[String] = []
    @State var gridItems:[GridItem] = [
        .init(.fixed(width3)),
        .init(.fixed(width3)),
        .init(.fixed(width3)),
    ]
    
    let uid:String
    init(_ uid:String) {
        self.uid = uid
    }
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing:20) {
                ForEach(ids, id:\.self) { id in
                    if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                        
                        NavigationLink(destination: {
                            PixelArtDetailView(id: id)
                        }, label: {
                            WebImage(url: model.imageURLvalue)
                                .placeholder(.imagePlaceHolder)
                                .resizable()
                                .frame(width: width3, height: width3, alignment: .center)
                        })
                    }
                }
            }
        }
        .onAppear {
            getListFromFirestore { ids, error in
                if let err = error {
                    toastMessage = err.localizedDescription
                    isShowToast = true
                }
                self.ids = ids
            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast,duration: 4)
    }
    
    private func getListFromFirestore(complete:@escaping(_ ids:[String], _ error:Error?)->Void) {
        collection.whereField("uid", isEqualTo: uid).order(by: "updateDt").getDocuments { snapShot, error in
            let realm = try! Realm()
            realm.beginWrite()
            var ids:[String] = []
            for doc in snapShot?.documents ?? [] {
                let data = doc.data()
                if let id = data["id"] as? String {
                    ids.append(id)
                    realm.create(SharedStageModel.self, value: data, update: .modified)
                }
            }
            try! realm.commitWrite()
            complete(ids, error)
        }
    }
}

struct ArtListView_Previews: PreviewProvider {
    static var previews: some View {
        ArtListView("")
    }
}
