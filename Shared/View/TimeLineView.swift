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
    @State var isLoading = false
    
    private var sortType:Sort.SortType {
        return Sort.SortTypeForMyGellery[sortIndex]
    }

    private func makeListView(gridItems:[GridItem], itemSize:CGSize) -> some View {
        LazyVGrid(columns: gridItems) {
            ForEach(ids, id:\.self) { id in
                NavigationLink {
                    PixelArtDetailView(id: id, showProfile: true)
                } label: {
                    if let model = try! Realm().object(ofType: SharedStageModelForTimeLine.self, forPrimaryKey: id) {
                        FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder)
                    } else {
                        Image.imagePlaceHolder.resizable()
                    }
                }
                .frame(width: itemSize.width,
                       height: itemSize.height,
                       alignment: .center)
                .onAppear {
                    if id == ids.last {
                        loadData()
                    }
                }
            }
            if isLoading {
                ActivityIndicator(isAnimating: $isLoading, style: .large)
                    .frame(width: itemSize.width,
                           height: itemSize.height,
                           alignment: .center)
            }
        }
    }

    private func makeListView(geomentrySize:CGSize) -> some View {
        makeListView(gridItems: Utill.makeGridItems(length: geomentrySize.width > geomentrySize.height ? 5 : 3,
                                                    screenWidth: geomentrySize.width,
                                                    padding: 20),
                     itemSize: Utill.makeItemSize(length: (geomentrySize.width > geomentrySize.height ? 5 : 3),
                                                  screenWidth: geomentrySize.width,
                                                  padding: 20))
        
    }
    
    var body : some View {
        GeometryReader { geomentry in
            if ids.count == 0 && isLoading {
                ActivityIndicator(isAnimating: $isLoading, style: .large)
                    .frame(width: geomentry.size.width, height: geomentry.size.height, alignment: .center)
            } else {
                ScrollView {
                    makeListView(geomentrySize: geomentry.size)
                }
            }
        }.onAppear(perform: loadData)
            .navigationTitle(Text("menu public load title"))
    }
    
    private func loadData() {
        var lastDt:TimeInterval? = nil
        if let id = ids.last {
            lastDt = try! Realm().object(ofType: SharedStageModelForTimeLine.self, forPrimaryKey: id)?.updateDt
        }
        isLoading = true
        DispatchQueue.global().async {
            queryManager.getTimeLine(order: sortType, lastDt: lastDt, limit: Consts.timelineLimit) { resultIds, error in
                DispatchQueue.main.async { [self] in
                    withAnimation {
                        isLoading = false
                        for id in resultIds {
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
