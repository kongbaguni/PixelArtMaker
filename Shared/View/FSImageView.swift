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
    @State var isLoading:Bool = false
    @State var hasError:Bool = false
    var body : some View {
        ZStack {
            if hasError {
                Image.errorImage
                    .background(Color.gray)
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
            if isLoading && !hasError {
                ActivityIndicator(isAnimating: $isLoading, style: .medium)
            }
        }

    }
}

