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
    
    @State var list:[LikeModel] = []
    @State var toastMessage:String = ""
    @State var isToast = false
    @State var isNeedMore = false
    @State var isNSFWDic:[LikeModel:Bool] = [:]
    
    @State var isLoading = false
    
    @State var changeLikeModel:(model:LikeModel,isLike:Bool)? = nil
    @State var isNeedReload = false
    
    var moreButton : some View {
        NavigationLink {
            LikeArtListFullView(uid: uid)
                .navigationTitle(Text("profile view like arts"))
        } label: {
            Text("more title")
        }
    }
    
    func getListFromFirebase(complete:@escaping(_ ids:[LikeModel], _ error:Error?)->Void) {
        FirestoreHelper.PublicArticle.getLikeList(uid: uid, list: list, isLimited: isLimited, complete: complete)
    }
    
    
    private func makeLikeView(model:LikeModel)-> some View {
        VStack {
            NavigationLink {
                PixelArtDetailView(id: model.documentId, showProfile: true)
            } label: {
                if itemSize.width > 0 && itemSize.height > 0 {
                    FSImageView(imageRefId: model.imageRefId, placeholder: .imagePlaceHolder, isNSFW: isNSFWDic[model] == true)
                        .frame(width: itemSize.width, height: itemSize.height, alignment: .center)
                }
            }.onAppear {
                if let isNSFW = SharedStageModel.findBy(id: model.documentId)?.isNSFW {
                    isNSFWDic[model] = isNSFW
                    return
                }
                SharedStageModel.findBy(id: model.documentId) { isDeleted, error in
                    if let isNSFW = SharedStageModel.findBy(id: model.documentId)?.isNSFW {
                        isNSFWDic[model] = isNSFW
                    }
                }
            }
        }
        
    }
    
    var listView : some View {
        LazyVGrid(columns: gridItems, spacing:20) {
            ForEach(list, id:\.self) { model in
                makeLikeView(model: model)
                    .onAppear {
                        if isLimited == false && model == list.last
                            && list.count > 0 && list.count % Consts.profileImageLimit == 0 {
                            getListFromFirebase { result, error in
                                for model in result {
                                    if list.firstIndex(of: model) == nil {
                                        withAnimation (.easeInOut){
                                            list.append(model)
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
    
    var body: some View {
        Group {
            if list.count > 0 {
                if isLimited {
                    VStack {
                        listView
                        if isNeedMore {
                            moreButton
                        }
                    }
                } else {
                    listView
                }
            } else {
                HStack {
                    Spacer()
                    Text(isLoading ? "loading like art gallery" : "empty like list message")
                        .padding(50)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }.onAppear {
            if isNeedReload {
                list.removeAll()
                isNeedReload = false
            }
            if list.count == 0 {
                isLoading = true
                getListFromFirebase { result, error in
                    withAnimation (.easeInOut){
                        list = result
                    }
                    isNeedMore = result.count == Consts.profileImageLimit
                    toastMessage = error?.localizedDescription ?? ""
                    isToast = error != nil
                    isLoading = false
                }
            }
            if let data = changeLikeModel {
                let model = data.model
                let docId = model.documentId
                let isLike = data.isLike
                
                let models = list.filter { model in
                    return model.documentId == docId
                }
                
                if isLike == false {
                    for m in models {
                        if let idx = list.firstIndex(of: m) {
                            list.remove(at: idx)
                        }
                    }
                }
                else {
                    for m in models {
                        if let idx = list.firstIndex(of: m) {
                            list.remove(at: idx)
                        }
                        list.insert(m, at: 0)
                    }
                }
                changeLikeModel = nil
            }
            NotificationCenter.default.addObserver(forName: .likeArticleDataDidChange, object: nil, queue: nil) { noti in
                if changeLikeModel != nil {
                    isNeedReload = true
                    changeLikeModel = nil
                }
                else if let userInfo = noti.userInfo {
                    if let isLike  = userInfo["isLike"] as? Bool,
                       let model = noti.object as? LikeModel {
                        changeLikeModel = (model:model,isLike:isLike)
                    }
                }
                
            }
        }
        .toast(message: toastMessage, isShowing: $isToast, duration: 4)
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
