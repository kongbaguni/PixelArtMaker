//
//  FSImageView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

/** 파이어스토어 이미지 보여주는 뷰 */
struct FSImageView : View {
    let imageRefId:String
    let placeholder:Image
    @State var imageURL:URL? = nil
    @State var toastMessage:String = ""
    @State var isShowToast:Bool = false
    
    var body : some View {
        WebImage(url: imageURL)
            .placeholder(placeholder.resizable())
            .resizable()
            .onAppear {
                FirebaseStorageHelper.shared.getDownloadURL(id: imageRefId) { url, error in
                    imageURL = url
                    toastMessage = error?.localizedDescription ?? ""
                    isShowToast = error != nil
                }
            }
            .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
    }
}

