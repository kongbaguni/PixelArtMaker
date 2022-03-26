//
//  SigninView.swift
//  PixelArtMaker
//
//  Created by Changyul Seo on 2022/03/11.
//

import SwiftUI

import FirebaseAuth

struct SigninView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            if AuthManager.shared.isSignined == false {
                Button {
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess in
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Apple 로 로그인")
                }
            } else {
                Button {
                    do {
                        try AuthManager.shared.auth.signOut()
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    Text("로그아웃")
                }
            }

        }.onAppear {
            if AuthManager.shared.auth.currentUser == nil {
                print("로그인 안했다")
            }
            else {
                print("로그인 했다")
            }
            
        }
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}

