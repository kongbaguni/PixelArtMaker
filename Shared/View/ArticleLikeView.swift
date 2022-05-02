//
//  ArticleLikeView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/29.
//

import SwiftUI
import FirebaseFirestore

struct ArticleLikeView: View {    
    let documentId:String
    let haveRightSpacer:Bool
    @State var isMyLike = false
    @State var likeUids:[String] = []
    var body: some View {
        HStack {
            Image(isMyLike ? "heart_red" : "heart_gray")
                .padding(5)
            Text(likeUids.count.formatted(.number))
                .font(.system(size: 10))
                .foregroundColor(.k_normalText)
            if haveRightSpacer {
                Spacer()
            }
        }.onAppear {
            FirestoreHelper.getLikePeopleIds(documentId: documentId) { uids, error in
                isMyLike = uids.firstIndex(of: AuthManager.shared.userId!) != nil
                likeUids = uids
            }
        }
    }
}

