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
        VStack {
            if AuthManager.shared.isSignined == false {
                
                Button {
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess in
                        if loginSucess {
                            ProfileModel.downloadProfile { error in
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Apple 로 로그인")
                }
                
                Button {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess in
                        if loginSucess {
                            ProfileModel.downloadProfile { error in
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Google ID 로 로그인")
                }
                
                Button {
                    AuthManager.shared.startSignInAnonymously { loginSucess in
                        if loginSucess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("익명 로그인")
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
        }.onDisappear {
            if let user = AuthManager.shared.auth.currentUser {
                if ProfileModel.currentUser == nil {
                    
                    ProfileModel.updateProfile(nickname: user.displayName ?? "",
                                               profileURL: user.photoURL?.absoluteString ?? "",
                                               email: user.email ?? "" ) { error in
                        
                    }
                }
            }
        }
        
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}

