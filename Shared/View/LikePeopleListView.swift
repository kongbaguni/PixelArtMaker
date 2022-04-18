//
//  LikePeopleListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/18.
//

import SwiftUI
import SDWebImageSwiftUI

struct LikePeopleView : View {
    let uid:String
    @State var profileImageURL:URL? = nil
    @State var name:String? = nil
    var body: some View {
        ZStack {
            if let url = profileImageURL {
               WebImage(url: url)
                    .resizable()
            }
            else {
                Image.profilePlaceHolder
                    .resizable()
            }
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
        }.onAppear {
            ProfileModel.downloadProfile(uid: uid, isCreateDefaultProfile: false) { error in
                let model = ProfileModel.findBy(uid: uid)
                profileImageURL = model?.profileImageURL
                name = model?.nickname
            }
        }
    }
}

struct LikePeopleShortListView : View {
    let uids:[String]
    var body : some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(uids,id:\.self) { uid in                    
                    NavigationLink {
                        ProfileView(uid: uid, haveArtList: true, editable: false, landScape: nil)
                    } label: {
                        LikePeopleView(uid: uid)
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                }
            }
        }
    }
}
