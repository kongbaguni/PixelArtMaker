//
//  SigninButton.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/07.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct AuthorizationButton : View {
    
    enum ProviderType {
        case apple
        case google
    }

    enum ButtonSize {
        case small
        case large
    }
    
    enum AuthType {
        case signin
        case signup
    }
    
    let provider:ProviderType
    let sizeType:ButtonSize
    let authType:AuthType
    let action:()->Void

    private var headImage:Image {
        switch provider {
        case .apple:
            return Image("signin_logo_apple").resizable()
        case .google:
            return Image("signin_logo_google").resizable()
        }
    }

    private var text:Text {
        switch provider {
        case .apple:
            switch authType {
            case .signin:
                return Text("Sign in with Apple")
            case .signup:
                return Text("Sign up with Apple")
            }
        case .google:
            switch authType {
            case .signin:
                return Text("Sign in with Google")
            case .signup:
                return Text("Sign up with Google")
            }
        }
    }
    
    private var backgroundColor:Color {
        switch provider {
        case .apple:
            return .k_signInBtnBackgroundApple
        case .google:
            return .k_signInBtnBackgroundGoogle
        }
    }
    
    private var btnLabel : some View {
        Group {
            switch sizeType {
            case .small:
                headImage.frame(width: 30, height: 30, alignment: .center)
            case .large:
                HStack {
                    Spacer()
                    headImage
                        .frame(width: 50, height: 50, alignment: .leading)
                        .padding(5)
                    text
                        .foregroundColor(.k_signInBtnBorder)
                        .font(.headline)
                    Spacer()
                }
            }
        }
    }
    
    var body : some View {
        Button {
            action()
        } label : {
            btnLabel
        }
        .background(backgroundColor)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30).stroke(Color.k_signInBtnBorder, lineWidth:1)
        )
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}
