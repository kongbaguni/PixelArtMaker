//
//  ArtListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/06.
//

import SwiftUI
import RealmSwift
import SDWebImageSwiftUI

extension Notification.Name {
    static let articleListSortTypeDidChanged = Notification.Name("articleListSortTypeDidChanged_observer")
}

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
                                FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder, isNSFW: model.isNSFW)
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
    
    let uid:String
    @State var sort:Sort.SortType = .latestOrder
    let gridItems:[GridItem]
    let itemSize:CGSize
    let isLimited:Bool
    @State var isNeedMore = false
    @State var ids:[String] = []
    @State var toastMessage = ""
    @State var isToast = false
    @State var isNeedReload = false
    var moreBtn : some View {
        NavigationLink {
            ArtListView(uid: uid, navigationTitle: Text("profile view public arts"))
        } label: {
            Text("more title")
        }
    }

    var list : some View {
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
    
    var body : some View {
        Group {
            if ids.count == 0 {
                Text("empty public shard list message")
                    .foregroundColor(.k_weakText)
                    .font(.subheadline)
            } else {
                if isLimited {
                    VStack {
                        list
                        if isNeedMore {
                            moreBtn
                        }
                    }
                } else {
                    list
                }
            }
        }
        .onAppear {
            if ids.count == 0 {
                loadFirst()
            }
            if isLimited == false {
                NotificationCenter.default.addObserver(forName: .articleListSortTypeDidChanged, object: nil, queue: nil) { noti in
                    if let type = noti.object as? Sort.SortType {
                        sort = type
                    }
                    ids.removeAll()
                    loadFirst()
                }
            }
            NotificationCenter.default.addObserver(forName: .likeArticleDataDidChange, object: nil, queue: nil) { noti in
                if sort == .like {
                    isNeedReload = true
                }
            }
            if isNeedReload {
                ids.removeAll()
                loadFirst()
                isNeedReload = false
            }
        }
        .toast(message: toastMessage, isShowing: $isToast, duration: 4)
    }
    
    private func loadFirst() {
        loadData { result, error in
            ids = result
            toastMessage = error?.localizedDescription ?? ""
            isToast = error != nil
            isNeedMore = result.count == Consts.profileImageLimit
        }
    }
    
    func loadData(complete:@escaping(_ ids:[String], _ error:Error?)->Void) {
        FirestoreHelper.PublicArticle.getList(uid: uid, isLimited: isLimited, ids: ids, sort: sort, complete: complete)
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
            NotificationCenter.default.post(name: .articleListSortTypeDidChanged, object: Sort.SortType.allCases[newValue])
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            ScrollView {
                makePickerView()
                if geomentry.size.width > geomentry.size.height {
                    ArticleListView(uid: uid,
                                    gridItems: Utill.makeGridItems(length: 5, screenWidth: geomentry.size.width, padding:20),
                                    itemSize: Utill.makeItemSize(length: 5, screenWidth: geomentry.size.width, padding:20),
                                    isLimited: false)
                    .frame(width:geomentry.size.width)
                    
                    
                } else {
                    ArticleListView(uid: uid,
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

