//
//  TimeLineView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/27.
//

import SwiftUI
import RealmSwift

struct TimeLineView : View {
    
    @State var ids:[String] = []

    @State var toastMessage = ""
    @State var isShowToast = false
    @State var isLoading = false
    @State var listTypeSelection = 0
    var listType:ListType {
        return ListType.allCases[listTypeSelection]
    }
    
    
    private var listTypePickerView : some View {
        Picker(selection: $listTypeSelection) {
            Image(systemName: ListType.grid.rawValue).tag(0)
            Image(systemName: ListType.list.rawValue).tag(1)
        } label: {
            Text("list type")
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: listTypeSelection) { newValue in
            UserDefaults.standard.timeLineListType = listType
        }
    }
    
    private func makeGridListView(gridItems:[GridItem], itemSize:CGSize) -> some View {
        LazyVGrid(columns: gridItems) {
            ForEach(ids, id:\.self) { id in
                NavigationLink {
                    PixelArtDetailView(id: id, showProfile: true)
                } label: {
                    if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                        FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder, isNSFW: model.isNSFW)
                    } else {
                        Image.imagePlaceHolder.resizable()
                    }
                }
                .frame(width: itemSize.width,
                       height: itemSize.height,
                       alignment: .center)
                .onAppear {
                    if id == ids.last  {
                        loadData(isLast: true)
                    }
                    if id == ids.first {
                        loadData(isLast: false)
                    }
                }
            }            
        }
    }

    private func makeNormalListView()-> some View {
        LazyVStack {
            ForEach(ids, id:\.self) { id in
                NavigationLink {
                    PixelArtDetailView(id: id, showProfile: true)
                } label: {
                    if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                        HStack {
                            FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder, isNSFW: model.isNSFW)
                                .frame(width: 150, height: 150, alignment: .leading)
                                .padding(.trailing,10)
                            VStack {
                                HStack {
                                    Text("reg dt").font(.headline)
                                        .foregroundColor(.K_boldText)
                                    Text(model.regDate.formatted(date: .numeric, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundColor(.k_weakText)
                                    Spacer()
                                }
                                HStack {
                                    Text("update dt").font(.headline)
                                        .foregroundColor(.K_boldText)
                                    Text(model.updateDate.formatted(date: .numeric, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundColor(.k_weakText)
                                    Spacer()
                                }
                                ArticleLikeView(documentId: id, haveRightSpacer: true)
                                Spacer()
                                HStack {
                                    Spacer()
                                    SimplePeopleView(uid: model.uid, size: 40)
                                        .padding(.trailing,5)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    if id == ids.last {
                        loadData(isLast: true)
                    }
                    if id == ids.first {
                        loadData(isLast: false)
                    }
                }
            }
        }
    }
    
    private func makeListView(geomentrySize:CGSize) -> some View {
        Group {
            NativeAdView().padding(.top,20).padding(.bottom,10)
            
            switch listType {
            case .grid:
                makeGridListView(gridItems: Utill.makeGridItems(length: geomentrySize.width > geomentrySize.height ? 5 : 3,
                                                            screenWidth: geomentrySize.width,
                                                            padding: 20),
                             itemSize: Utill.makeItemSize(length: (geomentrySize.width > geomentrySize.height ? 5 : 3),
                                                          screenWidth: geomentrySize.width,
                                                          padding: 20))
            case .list:
                makeNormalListView()
            }
        }
        
    }
    
    var body : some View {
        GeometryReader { geomentry in
            if ids.count == 0 && isLoading {
                ActivityIndicator(isAnimating: $isLoading, style: .large)
                    .frame(width: geomentry.size.width, height: geomentry.size.height, alignment: .center)
            } else {
                VStack {
                    listTypePickerView
                    ScrollView {
                        makeListView(geomentrySize: geomentry.size)
                    }
                }
            }
        }
        .onAppear {
            if ids.count == 0 {
                isLoading = true
                FirestoreHelper.Timeline.getTimeLine(order: .latestOrder, limit: Consts.timelineLimit) { resultIds, error in
                    ids = resultIds
                    toastMessage = error?.localizedDescription ?? ""
                    isShowToast = error != nil
                    isLoading = false
                }
            }
        }
        .navigationTitle(Text("menu public load title"))
    }
    
    private func loadData(isLast:Bool = true) {
        isLoading = true
        var indexDt:TimeInterval? = nil
        let id = isLast ? ids.last : ids.first
        if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
            indexDt = model.updateDt
        }
        FirestoreHelper.Timeline.getTimeLine(order: .latestOrder, indexDt: indexDt, isLast: isLast, limit: Consts.timelineLimit) { resultIds, error in
            if isLast {
                for id in resultIds {
                    if ids.firstIndex(of: id) == nil {
                        ids.append(id)
                    }
                }
            } else {
                for id in resultIds.reversed() {
                    if ids.firstIndex(of: id) == nil {
                        ids.insert(id, at: 0)
                    }
                }
            }
            toastMessage = error?.localizedDescription ?? ""
            isShowToast = error != nil
            isLoading = false
        }

    }
    
}
