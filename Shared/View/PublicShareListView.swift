//
//  PublicShareListView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import SwiftUI
import RealmSwift
import SDWebImageSwiftUI

struct PublicShareListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var dblist:Results<SharedStageModel> {
        let db = try! Realm().objects(SharedStageModel.self).filter("deleted = %@", false)
            
        switch sortType {
        case .latestOrder:
            return db.sorted(byKeyPath: "updateDt",ascending: true)
        case .oldnet:
            return db.sorted(byKeyPath: "updateDt",ascending: false)
        case .like:
            return db.sorted(byKeyPath: "likeCount",ascending: true)
        }
    }
    
    @State var isShowToast = false
    @State var toastMessage:String = ""
    @State var idlist:[String] = []
    @State var pictureId:String = ""
    @State var isShowPictureDetail = false
    @State var sortIndex = 0
    @State var isLoading = false

    var sortType:Sort.SortType {
        return Sort.SortTypeForPublicGallery[sortIndex]
    }
    
    private func makePickerView()->some View {
        Picker(selection:$sortIndex, label:Text("sort")) {
            ForEach(0..<Sort.SortTypeForPublicGallery.count, id:\.self) { idx in
                let type = Sort.SortTypeForPublicGallery[idx]
                Sort.getText(type: type)
            }
        }.onChange(of: sortIndex) { newValue in
            load()
        }
    }
    
    private func getWidth(length:Int, width:CGFloat)->CGFloat {
        return (width - 20) / CGFloat(length)
    }
    
    private func makeListView(gridItems:[GridItem], width:CGFloat)->some View {
        ScrollView {
            BannerAdView(sizeType: .GADAdSizeBanner,padding:.init(top: 20, left: 0, bottom: 20, right: 0))
            makePickerView()
            LazyVGrid(columns: gridItems, spacing:20) {
                ForEach(idlist, id:\.self) { id in
                    if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                        Button {
                            pictureId = model.id
                            isShowPictureDetail = true
                        } label: {
                            VStack {
                                ZStack {
                                    FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder, isNSFW: model.isNSFW)
                                        .frame(width: getWidth(length: gridItems.count, width: width),
                                               height: getWidth(length: gridItems.count, width: width), alignment: .center)
                                    
                                    if model.isNew {
                                        VStack {
                                            HStack {
                                                TagView(Text("NEW"))
                                                    .padding(5)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                
                                switch sortType {
                                case .like:
                                    ArticleLikeView(documentId: id, haveRightSpacer: false)
                                default:
                                    Text(model.updateDate.formatted(date: .long, time: .standard ))
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                    
                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
            .opacity(isLoading ? 0.5 : 1.0)
            .animation(.easeInOut, value: isLoading)
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            VStack {
                //MARK: - Navigation
                NavigationLink(isActive: $isShowPictureDetail) {
                    PixelArtDetailView(id:pictureId, showProfile: true)
                } label: {
                    
                }
                
                if idlist.count == 0 {
                    Text("empty public shard list message")
                }
                else {
                    ZStack {
                        if isLoading {
                            ActivityIndicator(isAnimating: $isLoading, style: .large)
                        }
                        makeListView(gridItems:
                                        geomentry.size.width > geomentry.size.height
                                     ? Utill.makeGridItems(length: 5, screenWidth: geomentry.size.width, padding:5)
                                     : Utill.makeGridItems(length: 3, screenWidth: geomentry.size.width, padding:5)
                                     ,width: geomentry.size.width
                        )
                    }
                }
            }
        }
        .onAppear {
            load()
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
        .navigationTitle(Text("public shared list"))
        
        
    }

    
    func load() {
        isLoading = true
        
        StageManager.shared.loadSharedList(sort: sortType, limit: 50) { error in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {[self] in
                isLoading = false
            }
            idlist = dblist.reversed().map({ model in
                return model.id
            })
            toastMessage = error?.localizedDescription ?? ""
            isShowToast = error != nil
        }
        idlist = dblist.reversed().map({ model in
            return model.id
        })
    }
}

struct PublicShareListView_Previews: PreviewProvider {
    static var previews: some View {
        PublicShareListView()
    }
}
