//
//  PublicShareListView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import SwiftUI
import RealmSwift

fileprivate let width1 = screenBounds.width - 10
fileprivate let width2 = screenBounds.width / 2 - 10
fileprivate let width3 = screenBounds.width / 3 - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50


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
    
    var pwidth:CGFloat {
        switch list.count {
        case 1:
            return width1
        case 2:
            return width2
        default:
            return width3
        }
    }
    
    @State var isShowToast = false
    @State var toastMessage:String = ""
    @State var list:[SharedStageModel] = [] {
        didSet {
            switch list.count {
            case 0:
                gridItems = []
            case 1:
                gridItems = [
                    .init(.fixed(width1))
                ]
            case 2:
                gridItems = [
                    .init(.fixed(width2)),
                    .init(.fixed(width2))
                ]
            default:
                gridItems = [
                    .init(.fixed(width3)),
                    .init(.fixed(width3)),
                    .init(.fixed(width3)),
                ]
            }
        }
    }
    
    @State var gridItems:[GridItem] = [
        .init(.fixed(width3)),
        .init(.fixed(width3)),
        .init(.fixed(width3)),
    ]

    @State var pictureId:String = ""
    @State var isShowPictureDetail = false

    @State var sortIndex = 0
    @State var isLoading = false
    
    var sortType:Sort.SortType {
        return Sort.SortTypeForPublicGallery[sortIndex]
    }
    
    var body: some View {
        VStack {
            //MARK: - Navigation
            NavigationLink(isActive: $isShowPictureDetail) {
                PixelArtDetailView(id:pictureId)
            } label: {
                
            }


            if list.count == 0 {
                Text("empty public shard list message")
            }
            else {
                ZStack {
                    if isLoading {
                        ActivityIndicator(isAnimating: $isLoading, style: .large)
                    }
                    ScrollView {
                        Picker(selection:$sortIndex, label:Text("sort")) {
                            ForEach(0..<Sort.SortTypeForPublicGallery.count, id:\.self) { idx in
                                let type = Sort.SortTypeForPublicGallery[idx]
                                Sort.getText(type: type)
                            }
                        }.onChange(of: sortIndex) { newValue in
                            load()
                        }
                        
                        LazyVGrid(columns: gridItems, spacing:20) {
                            ForEach(list, id:\.self) { model in
                                if let image = model.imageValue {
                                    Button {
                                        pictureId = model.id
                                        isShowPictureDetail = true
                                    } label: {
                                        VStack {
                                            ZStack {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .frame(width: pwidth, height: pwidth, alignment: .center)
                                                
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
                                            
                                            TagView(Text(model.updateDate.formatted(date: .long, time: .standard )))
                                        }
                                    }
                                    
                                }
                            }
                                                     
                        }
                        .opacity(isLoading ? 0.5 : 1.0)
                        .animation(.easeInOut, value: isLoading)
                        
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
            list = dblist.reversed()
            toastMessage = error?.localizedDescription ?? ""
            isShowToast = error != nil
        }
        list = dblist.reversed()
    }
}

struct PublicShareListView_Previews: PreviewProvider {
    static var previews: some View {
        PublicShareListView()
    }
}
