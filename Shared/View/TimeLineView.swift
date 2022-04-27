//
//  TimeLineView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/27.
//

import SwiftUI
import RealmSwift

struct TimeLineView : View {
    let queryManager = TimeLineManager()
    @State var ids:[String] = []
    @State var sortIndex = 0

    @State var toastMessage = ""
    @State var isShowToast = false
    
    var sortType:Sort.SortType {
        return Sort.SortTypeForMyGellery[sortIndex]
    }
    

    func makeListView(geomentrySize:CGSize) -> some View {
        LazyVGrid(columns: Utill.makeGridItems(length: geomentrySize.width > geomentrySize.height ? 5 : 3,
                                               screenWidth: geomentrySize.width,
                                               padding: 20)) {
            ForEach(ids, id:\.self) { id in
                NavigationLink {
                    PixelArtDetailView(id: id, showProfile: true)
                } label: {
                    if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                        FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder)
                    } else {
                        Image.imagePlaceHolder.resizable()
                    }
                }
                .frame(width: Utill.makeItemSize(length: (geomentrySize.width > geomentrySize.height ? 5 : 3),
                                                 screenWidth: geomentrySize.width,
                                                 padding: 20).width,
                       height: Utill.makeItemSize(length: (geomentrySize.width > geomentrySize.height ? 5 : 3),
                                                  screenWidth: geomentrySize.width,
                                                  padding: 20).height,
                       alignment: .center)
                .onAppear {
                    if id == ids.last {
                        loadData()
                    }
                }
            }
        }
    }
    
    var body : some View {
        GeometryReader { geomentry in
            ScrollView {
                makeListView(geomentrySize: geomentry.size)
            }
        }.onAppear(perform: loadData)
            .navigationTitle(Text("menu public load title"))
    }
    
    private func loadData() {
        var lastDt:TimeInterval? = nil
        if let id = ids.last {
            lastDt = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id)?.updateDt
        }
        DispatchQueue.global().async {
            queryManager.getTimeLine(order: sortType, lastDt: lastDt, limit: Consts.timelineLimit) { resultIds, error in
                DispatchQueue.main.async { [self] in
                    for id in resultIds {
                        withAnimation {
                            if try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id)?.deleted == false {
                                ids.append(id)
                            }
                        }
                    }
                    toastMessage = error?.localizedDescription ?? ""
                    isShowToast = error != nil
                }
            }
        }
    }
}
