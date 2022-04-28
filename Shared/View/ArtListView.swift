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

struct ArticleView : View {
    let id:String
    let itemSize:CGSize
    let sort:Sort.SortType
    
    var body : some View {
        Group {
            if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                NavigationLink(destination: {
                    PixelArtDetailView(id: id, showProfile: false)
                }, label: {
                    VStack {
                        if itemSize.width > 0 && itemSize.height > 0 {
                            FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder)
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
            } else {
                Image.imagePlaceHolder.resizable()
            }
        }
    }
}

struct ArticleListView : View {
    let collection = Firestore.firestore().collection("public")
    let uid:String
    let sort:Sort.SortType
    let gridItems:[GridItem]
    let itemSize:CGSize
    let isLimited:Bool
    
    @State var ids:[String] = []
    var body : some View {
        LazyVGrid(columns: gridItems, spacing:20) {
            ForEach(ids, id:\.self) { id in
                ArticleView(id: id, itemSize: itemSize, sort: sort)
                    .onAppear {
                        if id == ids.last {
                            if ids.count % Consts.timelineLimit == 0 {
                                if ids.count > 0 {
                                    if  isLimited == false {
                                        loadData()
                                    }
                                }
                            }
                        }
                    }
            }
        }.onAppear {
            ids = reloadFromLocalDb()
            loadData()
        }
    }
    
    func loadData() {
        let list = try! Realm().objects(SharedStageModel.self).filter("uid = %@",uid).sorted(byKeyPath: "updateDt")
        let lastSyncDt = list.first?.updateDt
        var query = collection
            .whereField("uid", isEqualTo: uid)
            .order(by: "updateDt", descending: true)
        
        if let time = lastSyncDt {
            query = query.whereField("updateDt", isLessThan: time)
        }
        query = query.limit(to: Consts.timelineLimit)
        
        query.getDocuments { snapshot, error in
            let realm = try! Realm()
            realm.beginWrite()
            for doc in snapshot?.documents ?? [] {
                let data = doc.data()
                if data["deleted"] as? Bool != true {
                    if let id = data["id"] as? String {
                        realm.create(SharedStageModel.self, value: data, update: .modified)
                        if self.ids.firstIndex(of: id) == nil {
                            ids.append(id)
                        }
                    }
                }
            }
            try! realm.commitWrite()
        }
    }
    
    /** 내가 공개한 작품의 목록을 로컬DB에서 읽어온다.*/
    func reloadFromLocalDb()->[String] {
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
        if isLimited {
            let limit = Consts.timelineLimit
            if limit > 0 && ids.count > limit {
                var newResult:[String] = []
                for i in 0..<limit {
                    newResult.append(ids[i])
                }
                return newResult
            }
        }

        return ids
    }
}

struct ArtListView: View {
        
    @State var isShowToast = false
    @State var toastMessage = ""
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
            isAnimate = true
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            ScrollView {
                makePickerView()
                if geomentry.size.width > geomentry.size.height {
                    ArticleListView(uid: uid,
                                    sort: sort,
                                    gridItems: Utill.makeGridItems(length: 5, screenWidth: geomentry.size.width, padding:20),
                                    itemSize: Utill.makeItemSize(length: 5, screenWidth: geomentry.size.width, padding:20),
                                    isLimited: false)
                    
                    
                } else {
                    ArticleListView(uid: uid,
                                    sort: sort,
                                    gridItems: Utill.makeGridItems(length: 3, screenWidth: geomentry.size.width, padding:20),
                                    itemSize: Utill.makeItemSize(length: 3, screenWidth: geomentry.size.width, padding:20),
                                    isLimited: false)
                  
                }
                
            }
            
        }
        
        .navigationTitle(Text(profile?.nickname ?? "unknown people"))
        .animation(.easeInOut, value: isAnimate)
        
        .toast(message: toastMessage, isShowing: $isShowToast,duration: 4)
    }
    
    
}

