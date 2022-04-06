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

    @State var nickname:String = ""
    @State var imageURL:URL? = nil
    @State var email:String = ""
     
    init(_ uid:String) {
        self.uid = uid
        print("profileview uid:\(uid)")
    }
    
    var body: some View {
        HStack {
            if let url = imageURL {
                WebImage(url: url)
                    .placeholder(.profilePlaceHolder)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            }
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
                    Text(nickname)
                        .font(.system(size: 10, weight: .light, design: .serif))
                        .foregroundColor(.gray)
                    Spacer()
                }
                HStack {
                    NavigationLink(destination: ArtListView(uid)) {
                        Text("art list")
                            .padding(5)
                            .font(.system(size: 10, weight: .heavy, design: .serif))

                    }
                    Spacer()
                }
            }
        }
        .padding(10)
        .onAppear {
            loadData()
            if uid.isEmpty == false {
                ProfileModel.findBy(uid: uid) { error in
                    loadData()
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
        ProfileView("test")
    }
}
