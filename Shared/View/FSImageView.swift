//
//  FSImageView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/22.
//

import SwiftUI
import SDWebImageSwiftUI
import RealmSwift

/** 파이어스토어 이미지 보여주는 뷰 */
struct FSImageView : View {
    let imageRefId:String
    let placeholder:Image
    @State var imageURL:URL? = nil
    @State var toastMessage:String = ""
    @State var isShowToast:Bool = false
    @State var isLoading:Bool = false
    var body : some View {
        ZStack {
            WebImage(url: imageURL)
                .placeholder(placeholder.resizable())
                .resizable()
                .onAppear {
                    let model = try! Realm().object(ofType: FirebaseStorageImageUrlCashModel.self, forPrimaryKey: imageRefId)
                    isLoading = model?.imageUrl == nil
                    imageURL = model?.imageUrl
                    
                    FirebaseStorageHelper.shared.getDownloadURL(id: imageRefId) { url, error in
                        isLoading = false
                        imageURL = url
                        toastMessage = error?.localizedDescription ?? ""
                        isShowToast = error != nil
                    }
                }
                .opacity(isLoading ? 0.0 : 1.0)
                .background(isLoading ? .gray : .clear)
            if isLoading {
                ActivityIndicator(isAnimating: $isLoading, style: .medium)
            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)

    }
}

