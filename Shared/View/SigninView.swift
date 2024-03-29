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
    @State var isShowToast = false
    @State var toastMessage = ""
    private func restoreInappPurchase() {
        inappPurchase.getProductInfo {
            inappPurchase.printStatus()
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
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
                            WebView(url: url, title:.init("term"))
                                
                        } label: {
                            Text("term")
                        }.padding(5)
                    }
                    
                    if let url = Bundle.main.url(forResource: "HTML/privacyPolicy", withExtension: "html") {
                        NavigationLink {
                            WebView(url: url, title:.init("privacyPolicy"))
                        } label: {
                            Text("privacyPolicy")
                        }.padding(5)
                    }
                    
                    if let url =  Bundle.main.url(forResource: "HTML/EULA", withExtension: "html") {
                        NavigationLink {
                            WebView(url: url, title:.init("EULA"))
                                
                        } label: {
                            Text("EULA")
                        }.padding(5)
                    }
                }
                
                
                if AuthManager.shared.isSignined == false {
                    //MARK: - Apple 로 로그인
                    AuthorizationButton(provider: .apple, sizeType: .large, authType: .signin) {
                        AuthManager.shared.startSignInWithAppleFlow { loginSucess, errorA in
                            if loginSucess {
                                FirestoreHelper.Profile.downloadProfile (isCreateDefaultProfile: true) { errorB in
                                    let error = errorA ?? errorB
                                    restoreInappPurchase()
                                    toastMessage = error?.localizedDescription ?? ""
                                    isShowToast = error != nil
                                    if error == nil {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                    }
                    //MARK: - Google 로 로그인
                    AuthorizationButton(provider: .google, sizeType: .large, authType: .signin) {
                        AuthManager.shared.startSignInWithGoogleId { loginSucess, errorA in
                            if loginSucess {
                                FirestoreHelper.Profile.downloadProfile (isCreateDefaultProfile: true) { errorB in
                                    let error = errorA ?? errorB
                                    restoreInappPurchase()
                                    toastMessage = error?.localizedDescription ?? ""
                                    isShowToast = error != nil
                                    if error == nil {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                    }
                    //MARK: - 익명 로그인
                    Button {
                        AuthManager.shared.startSignInAnonymously { loginSucess , error in
                            if loginSucess {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                toastMessage = error?.localizedDescription ?? ""
                                isShowToast = true
                            }
                        }
                    } label: {
                        Text("anonymous signin")
                    }

                }

            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}

