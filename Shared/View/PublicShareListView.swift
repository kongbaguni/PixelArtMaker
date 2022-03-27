//
//  PublicShareListView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import SwiftUI
import RealmSwift

fileprivate let width1 = screenBounds.width / 2 - 10
fileprivate let width2 = screenBounds.width - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50


struct PublicShareListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var dblist:Results<SharedStageModel> {
        return try! Realm().objects(SharedStageModel.self).filter("deleted = %@", false).sorted(byKeyPath: "updateDt")
    }
    
    @State var list:[SharedStageModel] = []
    @State var gridItems:[GridItem] = [
        .init(.fixed(width1)),
        .init(.fixed(width1))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing:20) {

                ForEach(list, id:\.self) { model in
                    if let image = model.imageValue {
                        Button {
                            if model.email == AuthManager.shared.auth.currentUser?.email {
                                StageManager.shared.openStage(id: model.documentId, email: model.email) { result in
                                    if result != nil {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        } label: {
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: width1, height: width1, alignment: .center)
                                TagView(Text(model.email))
                                TagView(Text(model.updateDate.formatted(date: .long, time: .standard )))
                            }
                        }

                    }
                }
            }
        }
        .onAppear {
            StageManager.shared.loadSharedList {
                list = dblist.reversed()
            }
            list = dblist.reversed()
        }
        .navigationTitle(Text("public shared list"))
        
        
    }
}

struct PublicShareListView_Previews: PreviewProvider {
    static var previews: some View {
        PublicShareListView()
    }
}
