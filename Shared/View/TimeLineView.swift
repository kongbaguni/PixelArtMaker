//
//  TimeLineView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/27.
//

import SwiftUI
import RealmSwift

struct TimeLineView : View {
    enum ListType : String, CaseIterable {
        case grid = "square.grid.3x3.fill"
        case list = "list.bullet"
    }
    
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
                        FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder)
                    } else {
                        Image.imagePlaceHolder.resizable()
                    }
                }
                .frame(width: itemSize.width,
                       height: itemSize.height,
                       alignment: .center)
                .onAppear {
                    if id == ids.last  {
                        loadData()
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
                            FSImageView(imageRefId: model.documentId, placeholder: .imagePlaceHolder)
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
                        loadData()
                    }
                }
            }
        }
    }
    
    private func makeListView(geomentrySize:CGSize) -> some View {
        Group {
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
        }.onAppear(perform: loadData)
            .navigationTitle(Text("menu public load title"))
    }
    
    private func loadData() {
        let type = UserDefaults.standard.timeLineListType
        listTypeSelection = ListType.allCases.firstIndex(of: type) ?? 0
        isLoading = true
        var lastDt:TimeInterval? = nil
        if let id = ids.last {
            lastDt = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id)?.updateDt
        }
        FirestoreHelper.Timeline.getTimeLine(order: .latestOrder, lastDt: lastDt, limit: Consts.timelineLimit) { resultIds, error in
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
