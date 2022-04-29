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
                            if model.deleted {
                                Image.errorImage.frame(width: itemSize.width, height: itemSize.height, alignment: .center)
                                    .background(Color.gray)
                            } else {
                                FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder)
                                    .frame(width: itemSize.width, height: itemSize.height, alignment: .center)
                            }
                        }
                        switch sort {
                        case .like:
                            ArticleLikeView(documentId: id, haveRightSpacer: false)
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
    @State var toastMessage = ""
    @State var isToast = false
    var body : some View {
        Group {
            if ids.count == 0 {
                Text("empty public shard list message")
                    .foregroundColor(.k_weakText)
                    .font(.subheadline)
            } else {
                LazyVGrid(columns: gridItems, spacing:20) {
                    ForEach(ids, id:\.self) { id in
                        ArticleView(id: id, itemSize: itemSize, sort: sort)
                            .onAppear {
                                let a = id == ids.last
                                let b = ids.count % Consts.profileImageLimit == 0
                                let c = ids.count > 0
                                let d = isLimited == false
                                if  a && b && c && d {
                                    loadData { result, error in
                                        for id in result {
                                            if ids.firstIndex(of: id) == nil {
                                                withAnimation (.easeInOut){
                                                    ids.append(id)
                                                }
                                            }
                                        }
                                        
                                        toastMessage = error?.localizedDescription ?? ""
                                        isToast = error != nil
                                    }
                                }
                            }
                    }
                }
            }
            
        }
        .onAppear {
            if ids.count == 0 {
                loadData { result, error in
                    withAnimation (.easeInOut){
                        ids = result
                    }
                    toastMessage = error?.localizedDescription ?? ""
                    isToast = error != nil
                }
            }
        }
    }
    
    func loadData(complete:@escaping(_ ids:[String], _ error:Error?)->Void) {
        var query = collection
            .whereField("uid", isEqualTo: uid)
            .order(by: "updateDt", descending: true)
    
        if isLimited == false {
            if let last = ids.last {
                if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: last) {
                    query = query.whereField("updateDt", isLessThan: model.updateDt)
                }
            }
        }
        query = query.limit(to: Consts.profileImageLimit)
        
        query.getDocuments { snapshot, error in
            let realm = try! Realm()
            if let documents = snapshot?.documents {
                var result:[String] = []
                realm.beginWrite()
                for doc in documents {
                    var data = doc.data()
                    data["id"] = doc.documentID
                    realm.create(SharedStageModel.self, value: data, update: .modified)
                    result.append(doc.documentID)
                }
                try! realm.commitWrite()
                complete(result, error)
            } else {
                complete([],error)
            }
        }
    }
    
   
}

struct ArtListView: View {
        
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var sortIndex:Int = 0
    @State var isAnimate:Bool = false
    
    let navigationTitle:Text?
    
    var sort:Sort.SortType {
        return Sort.SortType.allCases[sortIndex]
    }
        
    var profile:ProfileModel? {
        return ProfileModel.findBy(uid: uid)
    }
    
    
    let uid:String

    init(uid:String,  navigationTitle:Text?) {
        self.uid = uid
        self.navigationTitle = navigationTitle
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
                    .frame(width:geomentry.size.width)
                    
                    
                } else {
                    ArticleListView(uid: uid,
                                    sort: sort,
                                    gridItems: Utill.makeGridItems(length: 3, screenWidth: geomentry.size.width, padding:20),
                                    itemSize: Utill.makeItemSize(length: 3, screenWidth: geomentry.size.width, padding:20),
                                    isLimited: false)
                    .frame(width:geomentry.size.width)
                  
                }
                
            }
            
        }
        
        .navigationTitle(navigationTitle ?? Text(profile?.nickname ?? "unknown people"))
        .animation(.easeInOut, value: isAnimate)
        
        .toast(message: toastMessage, isShowing: $isShowToast,duration: 4)
    }
    
    
}

