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
    let inappPurchase = InAppPurchaseManager()
    private func restoreInappPurchase() {
        inappPurchase.getProductInfo {
            inappPurchase.printStatus()
        }
    }
    
    var body: some View {
        VStack {
            Text("Signin title")
                .font(.system(size: 30, weight: .heavy, design: .serif))
                .padding(10)
            Text("Signin desc")
                .font(.system(size: 15,weight: .regular, design: .serif))
                .foregroundColor(.gray)
                .padding(10)
            Spacer()
            
            HStack {
                if let url = Bundle.main.url(forResource: "HTML/term", withExtension: "html") {
                    NavigationLink {
                        WebView(url: url)
                            .navigationBarTitle(Text("term"))
                    } label: {
                        Text("term")
                    }.padding(5)
                }
                
                if let url = Bundle.main.url(forResource: "HTML/privacyPolicy", withExtension: "html") {
                    NavigationLink {
                        WebView(url: url)
                            .navigationBarTitle(Text("privacyPolicy"))
                    } label: {
                        Text("privacyPolicy")
                    }.padding(5)
                }
            }
            
            
            if AuthManager.shared.isSignined == false {
                //MARK: - Apple 로 로그인
                SignInWithAppleButton()
                    .frame(height:50)
                    .onTapGesture {
                        AuthManager.shared.startSignInWithAppleFlow { loginSucess in
                            if loginSucess {
                                ProfileModel.downloadProfile { error in
                                    restoreInappPurchase()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .padding(10)
                //MARK: - Google 로 로그인
                SignInWithGoogleButton()
                    .frame(height:80)
                    .padding(8)
                    .onTapGesture {
                        AuthManager.shared.startSignInWithGoogleId { loginSucess in
                            if loginSucess {
                                ProfileModel.downloadProfile { error in
                                    restoreInappPurchase()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }

            }

        }.onAppear {
            if let user = AuthManager.shared.auth.currentUser {
                if ProfileModel.currentUser == nil {
                    ProfileModel.updateProfile(nickname: user.displayName ?? "",
                                               profileURL: user.photoURL?.absoluteString ?? "",
                                               email: user.email ?? "" ) { error in
                        
                    }
                }
            }

        }.onDisappear {

        }
        
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}

