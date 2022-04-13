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
struct ArtListView: View {
        
    let collection = Firestore.firestore().collection("public")
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var ids:[String] = []
    
    @State var sortIndex:Int = 0
    @State var isAnimate:Bool = false
    
    let width:CGFloat?
    var sort:Sort.SortType {
        return Sort.SortType.allCases[sortIndex]
    }
        
    var profile:ProfileModel? {
        return ProfileModel.findBy(uid: uid)
    }
    
    
    let uid:String

    init(uid:String, width:CGFloat?) {
        self.uid = uid
        self.width = width
    }
        
    private func makePickerView()-> some View {
        Picker(selection:$sortIndex, label:Text("sort")) {
            ForEach(0..<Sort.SortType.allCases.count, id:\.self) { idx in
                let type = Sort.SortType.allCases[idx]
                Sort.getText(type: type)
            }
        }.onChange(of: sortIndex) { newValue in
            ids = ArtListView.reloadFromLocalDb(sort:sort)
            isAnimate = true
            ArtListView.getListFromFirestore(sort:sort) { ids, error in
                isAnimate = false
                self.ids = ids
            }
        }
    }
    
    static func makeListView(ids:[String], sort:Sort.SortType ,gridItems:[GridItem], itemSize:CGSize)-> some View {
        LazyVGrid(columns: gridItems, spacing:20) {
            ForEach(ids, id:\.self) { id in
                if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                    
                    NavigationLink(destination: {
                        PixelArtDetailView(id: id, showProfile: false)
                    }, label: {
                        VStack {
                            if itemSize.width > 0 && itemSize.height > 0 {
                                WebImage(url: model.imageURLvalue)
                                    .placeholder(.imagePlaceHolder)
                                    .resizable()
                                    .frame(width: itemSize.width, height: itemSize.height, alignment: .center)
                            }
                            
                            switch sort {
                            case .like:
                                HStack {
                                    Image(model.isMyLike ? "heart_red" : "heart_gray")
                                        .padding(5)
                                    Text(model.likeCount.formatted(.number))
                                        .font(.system(size: 10))
                                        .foregroundColor(.k_normalText)
                                }
                            default:
                                Text(model.updateDate.formatted(date: .long, time: .standard ))
                                    .font(.system(size: 10))
                                    .foregroundColor(.k_normalText)
                            }
                        }
                        
                        
                    })
                }
            }
        }
    }
    
    static func getListFromFirestore(sort:Sort.SortType,complete:@escaping(_ ids:[String], _ error:Error?)->Void) {
        guard let uid = AuthManager.shared.userId else {
            complete([],nil)
            return
        }
        var ids:[String] = []
        Firestore.firestore().collection("public")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { snapShot, error in
                let realm = try! Realm()
                realm.beginWrite()
                for doc in snapShot?.documents ?? [] {
                    let data = doc.data()
                    if let id = data["id"] as? String {
                        ids.append(id)
                        realm.create(SharedStageModel.self, value: data, update: .modified)
                    }
                }
                try! realm.commitWrite()
                print(error?.localizedDescription ?? "성공")
                complete(ArtListView.reloadFromLocalDb(sort: sort), error)
            }
    }
    /** 내가 공개한 작품의 목록을 로컬DB에서 읽어온다.*/
    static func reloadFromLocalDb(sort:Sort.SortType)->[String] {
        guard let uid = AuthManager.shared.userId else {
            return []
        }
        let db = try! Realm().objects(SharedStageModel.self).filter("uid = %@ && deleted = %@", uid, false)

        var result:Results<SharedStageModel>? = nil
        switch sort {
        case .latestOrder:
            result =  db.sorted(byKeyPath: "updateDt", ascending: true)
        case .oldnet:
            result = db.sorted(byKeyPath: "updateDt", ascending: false)
        case .like:
            result = db.sorted(byKeyPath: "likeCount", ascending: true)
        }
        let ids = (result?.reversed() ?? []).map({ model in
            return model.id
        })
        return ids
    }
    
    var body: some View {
        GeometryReader { geomentry in
            ScrollView {
                makePickerView()
                if geomentry.size.width > geomentry.size.height {
                    ArtListView.makeListView(
                        ids:ids,
                        sort:sort,
                        gridItems: GridItem.makeGridItems(length: 5, width: geomentry.size.width - 40),
                        itemSize: .init(width: ((width ?? geomentry.size.width) - 40) / 5,
                                        height: ((width ?? geomentry.size.width) - 40) / 5 + 10)
                    )
                    
                    
                } else {
                    ArtListView.makeListView(
                        ids:ids,
                        sort:sort,
                        gridItems: GridItem.makeGridItems(length: 3, width: geomentry.size.width - 40),
                        itemSize: .init(width: ((width ?? geomentry.size.width) - 40) / 3,
                                        height: ((width ?? geomentry.size.width) - 40) / 3 + 10)
                    )
                }
                
            }
            
        }
        
        .navigationTitle(Text(profile?.nickname ?? "unknown people"))
        .animation(.easeInOut, value: isAnimate)
        .onAppear {
            ArtListView.getListFromFirestore(sort:sort) { ids, error in
                if let err = error {
                    toastMessage = err.localizedDescription
                    isShowToast = true
                }
                self.ids = ids
            }
        }
        
        .toast(message: toastMessage, isShowing: $isShowToast,duration: 4)
    }
    
    
}

