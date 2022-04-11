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
    
    var body: some View {
        GeometryReader { geomentry in
            if haveArtList {
                if geomentry.size.height > geomentry.size.width {
                    VStack {
                        makeProfileView(isLandscape: false)
                        ArtListView(uid: uid, width: geomentry.size.width)
                    }
                }
                else {
                    HStack {
                        makeProfileView(isLandscape: true)
                            .frame(width:250)
                        ArtListView(uid: uid,
                                    width : geomentry.size.width - 250)
                        .frame(width: geomentry.size.width - 250)
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
