//
//  ReplyListView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReplyListView: View {
    enum ListMode {
        case 내가_쓴_댓글
        case 내_게시글에_달린_댓글
    }
    
    let uid:String
    let limit:Int
    let listMode:ListMode
    
    @State var replys:[ReplyModel] = []
    @State var isToast = false
    @State var toastMessage = ""
    @State var isLoading = false
    
    var body: some View {
        LazyVStack {
            if isLoading {
            }
            else if replys.count == 0 {
                Text("empty reply list message")
                    .font(.subheadline)
                    .foregroundColor(Color.k_weakText)
            }
            ForEach(replys, id:\.self) { reply in
                NavigationLink {
                    PixelArtDetailView(id: reply.documentId, showProfile: true, focusedReply: reply)
                } label: {
                    HStack {
                        VStack {
                            WebImage(url: URL(string:reply.imageURL))
                                .placeholder(.imagePlaceHolder.resizable())
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
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
                        if listMode == .내_게시글에_달린_댓글 {
                            VStack {
                                SimplePeopleView(uid: reply.uid, isSmall: true)
                                Spacer()
                            }                            
                        }
                    }
                }
                
            }
        }.onAppear {
            isLoading = true
            switch listMode {
            case .내가_쓴_댓글:
                ReplyManager.shared.getReplys(uid: uid, limit: limit) { result, error in
                    withAnimation(.easeInOut) {
                        isLoading = false
                        replys = result
                        toastMessage = error?.localizedDescription ?? ""
                        isToast = error != nil
                    }
                }
            case .내_게시글에_달린_댓글:
                ReplyManager.shared.getReplysToMe(uid: uid, limit: limit) { result, error in
                    withAnimation(.easeInOut) {
                        isLoading = false
                        replys = result
                        toastMessage = error?.localizedDescription ?? ""
                        isToast = error != nil
                    }
                }
            }
        }
        .toast(message: toastMessage, isShowing: $isToast, duration: 4)
    }
}


struct ReplyListFullView : View {
    let uid:String
    let listMode: ReplyListView.ListMode
    
    var body : some View {
        ScrollView {
            ReplyListView(uid: uid, limit: 0, listMode: listMode)
        }
    }
}
