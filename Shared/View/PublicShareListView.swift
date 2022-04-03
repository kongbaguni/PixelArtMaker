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
        return try! Realm().objects(SharedStageModel.self).filter("deleted = %@", false).sorted(byKeyPath: "updateDt")
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
                ScrollView {
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
                }
            }
        }
        .onAppear {
            StageManager.shared.loadSharedList { error in
                list = dblist.reversed()
                toastMessage = error?.localizedDescription ?? ""
                isShowToast = error != nil
            }
            list = dblist.reversed()
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
        .navigationTitle(Text("public shared list"))
        
        
    }
    
    func load() {
        
    }
}

struct PublicShareListView_Previews: PreviewProvider {
    static var previews: some View {
        PublicShareListView()
    }
}
