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
    @State var isNeedReload = false
    @State var isNeedMore = false
    
    
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
                    FSImageView(imageRefId: model.imageRefId, placeholder: .imagePlaceHolder)
                        .frame(width: itemSize.width, height: itemSize.height, alignment: .center)
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
                    Text("empty like list message")
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
                getListFromFirebase { result, error in
                    withAnimation (.easeInOut){
                        list = result
                    }
                    isNeedMore = result.count == Consts.profileImageLimit
                    toastMessage = error?.localizedDescription ?? ""
                    isToast = error != nil
                }
            }
            NotificationCenter.default.addObserver(forName: .likeArticleDataDidChange, object: nil, queue: nil) { noti in
                isNeedReload = true
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
