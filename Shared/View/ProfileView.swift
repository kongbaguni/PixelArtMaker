//
//  ProfileView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/02.
//

import SwiftUI
import SDWebImageSwiftUI
import RealmSwift

struct ProfileView: View {
    let uid:String
    let haveArtList:Bool
    let editabel:Bool
    let landScape:Bool?
    
    init(uid:String, haveArtList:Bool, editable:Bool = false, landScape:Bool? = nil) {
        self.uid = uid
        self.haveArtList = haveArtList
        self.editabel = editable
        self.landScape = landScape
    }
    
    @State var nickname:String = ""
    @State var imageURL:URL? = nil
    @State var email:String = ""
    @State var sortSelect = 0
    var sortList:[Sort.SortType] = Sort.SortTypeForPublicGallery
    var sort:Sort.SortType {
        sortList[sortSelect]
    }
    
    @State var sharedIds:[String] = []
    
    private func makeProfileImageView(size:CGFloat)-> some View {
        VStack {
            if let url = imageURL {
                WebImage(url: url)
                    .placeholder(.profilePlaceHolder)
                    .resizable()
                    .frame(width: size, height: size, alignment: .center)
            } else {
                Image.profilePlaceHolder
                    .resizable()
                    .frame(width: size, height: size, alignment: .center)
            }
        }
    }
    
    private func mkaeProfileInfomationView(isLandScape:Bool)-> some View {
        VStack {
            HStack {
                Text("email")
                    .font(.system(size: 10, weight: .heavy, design: .serif))
                    .padding(5)
                Button {
                    let urlstr = "mailto:\(email)"
                    if let url = URL(string: urlstr) {
                        UIApplication.shared.open(url)
                    }
                } label : {
                    Text(email)
                        .font(.system(size: 10, weight: .light, design: .serif))
                }
                Spacer()
            }
            HStack {
                Text("name")
                    .font(.system(size: 10, weight: .heavy, design: .serif))
                    .padding(5)
                if editabel {
                    TextField("name", text: $nickname)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(nickname)
                        .font(.system(size: 10, weight: .light, design: .serif))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            if haveArtList == false {
                HStack {
                    NavigationLink(destination: ArtListView(uid: uid, width:nil)) {
                        Text("art list")
                            .padding(5)
                            .font(.system(size: 10, weight: .heavy, design: .serif))
                        
                    }
                    Spacer()
                }
            }
            
        }
        
    }
    private func makeProfileView(isLandscape:Bool)-> some View {
        VStack {
            if isLandscape {
                ScrollView {
                    HStack {
                        makeProfileImageView(size: 200)
                        Spacer()
                    }
                    mkaeProfileInfomationView(isLandScape: isLandscape)
                }
            } else {
                HStack {
                    makeProfileImageView(size: 100)
                    mkaeProfileInfomationView(isLandScape: isLandscape)
                }
            }
        }
    }
    
    private func makeGridItems(length:Int, screenWidth:CGFloat)->[GridItem] {
        let item = GridItem(.fixed((screenWidth - 20) / CGFloat(length)))
        var result:[GridItem] = []
        for _ in 0..<length {
            result.append(item)
        }
        return result
    }
    
    private func makeItemSize(length:Int, screenWidth:CGFloat) -> CGSize {
        let width = (screenWidth - 20.0) / CGFloat(length)
        return .init(width: width, height: width + 10)
    }
    
    var body: some View {
        GeometryReader { geomentry in
            if haveArtList {
                if geomentry.size.height > geomentry.size.width {
                    ScrollView {
                        makeProfileView(isLandscape: false)
                        Section(header:Text("profile view public arts")) {
                            ArtListView.makeListView(ids: sharedIds, sort: sort,
                                                     gridItems: makeGridItems(length: 4, screenWidth: geomentry.size.width),
                                                     itemSize: makeItemSize(length: 4, screenWidth: geomentry.size.width))
                        }
                        Section(header:Text("profile view like arts")) {
                            LikeArtListView(uid: uid, gridItems: makeGridItems(length: 4, screenWidth: geomentry.size.width),
                                            itemSize: makeItemSize(length: 4, screenWidth: geomentry.size.width))
                        }
                        
                    }
                }
                else {
                    HStack {
                        makeProfileView(isLandscape: true)
                            .frame(width:250)
                        ScrollView {
                            Section(header:Text("profile view public arts")) {
                                ArtListView.makeListView(ids: sharedIds, sort: sort,
                                                         gridItems: makeGridItems(length: 6, screenWidth: geomentry.size.width - geomentry.size.height - 10),
                                                         itemSize: makeItemSize(length: 6, screenWidth: geomentry.size.width - geomentry.size.height - 10))
                            }
                            Section(header:Text("profile view like arts")) {
                                LikeArtListView(uid: uid, gridItems: makeGridItems(length: 6, screenWidth: geomentry.size.width - geomentry.size.height - 10),
                                                itemSize: makeItemSize(length: 6, screenWidth: geomentry.size.width - geomentry.size.height - 10))
                            }
                            
                        }
                    }
                }
            }
            else {
                HStack {
                    makeProfileView(isLandscape: landScape == true)
                }
            }
        }        
        .padding(10)
        .onAppear {
            NotificationCenter.default.addObserver(forName: .profileDidUpdated, object: nil, queue: nil) { notification in
                self.loadData()
            }
            sharedIds = ArtListView.reloadFromLocalDb(sort: sort)
            ArtListView.getListFromFirestore(sort: sort) { ids, error in
                self.sharedIds = ids
            }
            
            loadData()
            if uid.isEmpty == false {
                ProfileModel.findBy(uid: uid) { error in
                    loadData()
                }
            }
        }
        .onDisappear {
            if editabel {
                ProfileModel.updateProfile(nickname: nickname) { error in
                    
                }
            }
        }
        
    }
    
    private func loadData() {
        guard let user = try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid) else {
            return
        }
        nickname = user.nickname
        imageURL = URL(string: user.profileURL)
        email = user.email
        
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(uid: "", haveArtList: false)
    }
}
