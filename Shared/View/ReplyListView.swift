//
//  ReplyListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReplyListView: View {
    let uid:String
    let limit:Int
    @State var replys:[ReplyModel] = []
    @State var isToast = false
    @State var toastMessage = ""
    var body: some View {
        LazyVStack {
            ForEach(replys, id:\.self) { reply in
                HStack {
                    VStack {
                        NavigationLink {
                            PixelArtDetailView(id: reply.documentId, showProfile: true, focusedReply: reply)
                        } label: {
                            WebImage(url: URL(string:reply.imageURL))
                                .placeholder(.imagePlaceHolder.resizable())
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                        }
                        Spacer()
                    }
                    VStack {
                        HStack {
                            reply.updateDtText.font(.system(size: 10)).foregroundColor(.gray)
                            Spacer()
                        }
                        HStack {
                            Text(reply.message)
                                .font(.subheadline)
                                .foregroundColor(Color.k_normalText)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
            }
        }.onAppear {
            ReplyManager.shared.getReplys(uid: uid, limit: limit) { result, error in
                withAnimation(.easeInOut) {
                    replys = result
                    toastMessage = error?.localizedDescription ?? ""
                    isToast = error != nil
                }                
            }
        }
        .toast(message: toastMessage, isShowing: $isToast, duration: 4)
    }
}
