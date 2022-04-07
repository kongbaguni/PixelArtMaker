//
//  SigninButton.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/07.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct SignInWithAppleButton: UIViewRepresentable {
  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
      let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
      button.cornerRadius = 10
      return button
  }
  
  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

struct SignInWithGoogleButton: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()        
        button.colorScheme = .light
        button.style = .wide
        button.layer.cornerRadius = 10
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

