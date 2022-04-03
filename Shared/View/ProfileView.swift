//
//  ProfileView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/02.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @State var nickname:String = ProfileModel.currentUser?.nickname ?? "없음"
    @State var imageURL:URL? = ProfileModel.currentUser?.profileImageURL ?? nil
    @State var email:String = ProfileModel.currentUser?.email ?? "없음"
    @State var uid:String = ProfileModel.currentUser?.uid ?? "없음"
        
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
        .onAppear {
            ProfileModel.downloadProfile { isSucess in
                loadData()
            }
        }
        .navigationTitle(Text("profile"))
    }
    
    private func loadData() {
        guard let user = ProfileModel.currentUser else {
            return
        }
        uid = user.uid
        nickname = user.nickname
        imageURL = URL(string: user.profileURL)
        email = user.email
        print(user)
        
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
