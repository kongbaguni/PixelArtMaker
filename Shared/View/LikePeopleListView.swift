//
//  LikePeopleListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/18.
//

import SwiftUI
import SDWebImageSwiftUI

struct SimplePeopleView : View {
    let uid:String
    let isSmall:Bool
    @State var profileImageURL:URL? = nil
    @State var name:String? = nil
    var body: some View {
        Group {
            if isSmall {
                VStack {
                    if let url = profileImageURL {
                        WebImage(url: url)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    if let name = name {
                        Text(name)
                            .font(.system(size: 10))
                            .foregroundColor(Color.k_normalText)
                    }
                }
            }
            else {
                ZStack {
                    if let url = profileImageURL {
                        WebImage(url: url)
                            .resizable()
                    }
                    else {
                        Image.profilePlaceHolder
                            .resizable()
                    }
                    if !isSmall {
                        if let name = name {
                            VStack {
                                Spacer()
                                Text(name)
                                    .font(.subheadline)
                                    .padding(5)
                                    .background(Color.k_dim)
                                    .foregroundColor(.k_normalText)
                                    .cornerRadius(10)
                                    .padding(5)
                            }
                        }
                    }
                }
            }
        }.onAppear {
            if profileImageURL == nil {
                ProfileModel.downloadProfile(uid: uid, isCreateDefaultProfile: false) { error in
                    loadDataFromLocalDb()
                }
            }
            loadDataFromLocalDb()
        }
    }
    
    private func loadDataFromLocalDb() {
        if let model = ProfileModel.findBy(uid: uid) {
            profileImageURL = model.profileImageURL
            name = model.nickname
        }

    }
}

struct LikePeopleShortListView : View {
    let uids:[String]
    var body : some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(uids,id:\.self) { uid in
                    if uid.isEmpty == false {                        
                        NavigationLink {
                            ProfileView(uid: uid, haveArtList: true, editable: false, landScape: nil)
                                .navigationTitle(Text(ProfileModel.findBy(uid: uid)?.nickname ?? uid))
                        } label: {
                            SimplePeopleView(uid: uid, isSmall: false)
                                .frame(width: 100, height: 100, alignment: .center)
                        }
                    }
                }
            }
        }
    }
}
