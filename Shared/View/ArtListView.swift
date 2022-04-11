//
//  ArtListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/06.
//

import SwiftUI
import FirebaseFirestore
import RealmSwift
import SDWebImageSwiftUI
fileprivate let width1 = screenBounds.width - 10
fileprivate let width2 = screenBounds.width / 2 - 10
fileprivate let width3 = screenBounds.width / 3 - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50

struct ArtListView: View {
    static let grids3:[GridItem] = [.init(.fixed(width3)),.init(.fixed(width3)),.init(.fixed(width3))]
    
    static func makeGridItems(length:Int,width:CGFloat, padding:CGFloat = 10)->[GridItem] {
        var result:[GridItem] = []
        let width = (width / CGFloat(length)) + padding
        for _ in 0..<length {
            result.append(.init(.fixed(width)))
        }
        return result
    }
    
    let collection = Firestore.firestore().collection("public")
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var ids:[String] = []
    
    @State var sortIndex:Int = 0
    @State var isAnimate:Bool = false
    
    var sort:Sort.SortType {
        return Sort.SortType.allCases[sortIndex]
    }
        
    var profile:ProfileModel? {
        return ProfileModel.findBy(uid: uid)
    }
    
    let gridItems:[GridItem]
    
    let uid:String

    init(uid:String, gridItems:[GridItem]?) {
        self.uid = uid
        self.gridItems = gridItems ?? []
    }
    
    private func makePickerView()-> some View {
        Picker(selection:$sortIndex, label:Text("sort")) {
            ForEach(0..<Sort.SortType.allCases.count, id:\.self) { idx in
                let type = Sort.SortType.allCases[idx]
                Sort.getText(type: type)
            }
        }.onChange(of: sortIndex) { newValue in
            ids = reloadFromLocalDb()
        }
    }
    
    private func makeListView(gridItems:[GridItem])-> some View {
        LazyVGrid(columns: gridItems, spacing:20) {
            ForEach(ids, id:\.self) { id in
                if let model = try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: id) {
                    
                    NavigationLink(destination: {
                        PixelArtDetailView(id: id, showProfile: false)
                    }, label: {
                        VStack {
                            WebImage(url: model.imageURLvalue)
                                .placeholder(.imagePlaceHolder)
                                .resizable()
                                .frame(width: width3, height: width3, alignment: .center)
                            
                            switch sort {
                            case .like:
                                HStack {
                                    Image(model.isMyLike ? "heart_red" : "heart_gray")
                                        .padding(5)
                                    Text(model.likeCount.formatted(.number))
                                        .font(.system(size: 10))
                                        .foregroundColor(.k_normalText)
                                }
                            default:
                                Text(model.updateDate.formatted(date: .long, time: .standard ))
                                    .font(.system(size: 10))
                                    .foregroundColor(.k_normalText)
                            }
                        }
                        
                        
                    })
                }
            }
        }
    }
    
    private func getListFromFirestore(complete:@escaping(_ ids:[String], _ error:Error?)->Void) {
        collection
            .whereField("uid", isEqualTo: uid)
            .getDocuments { snapShot, error in
                let realm = try! Realm()
                realm.beginWrite()
                for doc in snapShot?.documents ?? [] {
                    let data = doc.data()
                    if let id = data["id"] as? String {
                        ids.append(id)
                        realm.create(SharedStageModel.self, value: data, update: .modified)
                    }
                }
                try! realm.commitWrite()
                print(error?.localizedDescription ?? "성공")
                complete(reloadFromLocalDb(), error)
            }
    }
    
    func reloadFromLocalDb()->[String] {
        let db = try! Realm().objects(SharedStageModel.self).filter("uid = %@ && deleted = %@", uid, false)

        var result:Results<SharedStageModel>? = nil
        switch sort {
        case .latestOrder:
            result =  db.sorted(byKeyPath: "updateDt", ascending: true)
        case .oldnet:
            result = db.sorted(byKeyPath: "updateDt", ascending: false)
        case .like:
            result = db.sorted(byKeyPath: "likeCount", ascending: true)
        }
        let ids = (result?.reversed() ?? []).map({ model in
            return model.id
        })
        isAnimate = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)) {
            isAnimate = false
        }
        return ids
    }
    
    var body: some View {
        Group {
            if gridItems.count > 0 {
                ScrollView {
                    makePickerView()
                    makeListView(gridItems: gridItems)
                }
            } else {
                GeometryReader { geomentry in
                    ScrollView {
                        makePickerView()
                        if geomentry.size.width > geomentry.size.height {
                            makeListView(gridItems:
                                            ArtListView.makeGridItems(length: 5, width: geomentry.size.width, padding: 0))
                            
                        } else {
                            makeListView(gridItems: ArtListView.grids3)
                        }
                        
                    }
                }
            }
        }
        .navigationTitle(Text(profile?.nickname ?? "unknown people"))
        .animation(.easeInOut, value: isAnimate)
        .onAppear {
            getListFromFirestore { ids, error in
                if let err = error {
                    toastMessage = err.localizedDescription
                    isShowToast = true
                }
                self.ids = ids
            }
        }
        
        .toast(message: toastMessage, isShowing: $isShowToast,duration: 4)
    }
    
    
}

