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
    let isNSFW:Bool
    let isNSFWunlock:Bool
    @State var isTouchedNSFW = false
    @State var imageURL:URL? = nil
    @State var isLoading:Bool = false
    @State var hasError:Bool = false
    @State var isShwoAlert:Bool = false
    
    init (imageRefId:String, placeholder:Image, isNSFW:Bool = false, isNSFWUnlock:Bool = false ) {
        self.imageRefId = imageRefId
        self.placeholder = placeholder
        self.isNSFW = isNSFW
        self.isNSFWunlock = isNSFWUnlock
    }
    
    var body : some View {
        ZStack {
            if hasError {
                Image.errorImage
                    .background(Color.gray)
            }
            else {
                if isNSFW && isTouchedNSFW == false {
                    if isNSFWunlock {
                        Button {
                            isTouchedNSFW = true
                        } label : {
                            ZStack {
                                Image("NSFW").resizable()
                                    .opacity(0.2)
                                Text("NSFW message")
                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color.k_signInBtnBackgroundApple)
                                    .shadow(color: Color.k_signInBtnBorder, radius: 10, x: 0, y: 0)
                                
                            }
                        }
                    } else {
                        Image("NSFW").resizable()
                    }
                }
                else {
                    WebImage(url: imageURL)
                        .placeholder(placeholder.resizable())
                        .resizable()
                        .onAppear {
                            if imageRefId.isEmpty {
                                return
                            }
                            var isNeedUpdate = true
                            if let model = try! Realm().object(ofType: FirebaseStorageImageUrlCashModel.self, forPrimaryKey: imageRefId) {
                                isLoading = false
                                imageURL = model.imageUrl
                                isNeedUpdate = model.isExpire
                                hasError = model.deleted && model.url.isEmpty
                            }
                            isLoading = imageURL == nil
                            
                            if isNeedUpdate {
                                FirebaseStorageHelper.shared.getDownloadURL(id: imageRefId) { url, error in
                                    isLoading = false
                                    imageURL = url
                                    hasError = error != nil
                                }
                            }
                        }
                        .opacity(isLoading ? 0.0 : 1.0)
                        .background(isLoading ? .gray : .clear)
                }
                
            }
            if isLoading && !hasError {
                ActivityIndicator(isAnimating: $isLoading, style: .medium)
            }
        }

    }
}

