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
    @State var nickname:String = ProfileModel.currentUser?.nickname ?? "없음"
    @State var imageURL:URL? = ProfileModel.currentUser?.profileImageURL ?? nil
    @State var email:String = ProfileModel.currentUser?.email ?? "없음"
    @State var uid:String = ProfileModel.currentUser?.uid ?? "없음"
     
    init(_ uid:String? = nil) {
        if let id = uid {
            self.uid = id
        }
    }
    
    var body: some View {
        HStack {
            if let url = imageURL {
                WebImage(url: url)
            }
            VStack {
                LabelTextView(label: "uid", text: uid)
                LabelTextView(label: "email", text: email)
                LabelTextView(label: "name", text: nickname)
                
            }
        }
        .padding(10)
        .onAppear {
            ProfileModel.findBy(uid: uid) { error in
                loadData()
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
        ProfileView()
    }
}
