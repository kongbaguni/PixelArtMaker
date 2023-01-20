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
        case 내가_좋아요한_댓글
    }
    
    let uid:String
    let isLimited:Bool
    let listMode:ListMode
    
    @State var replys:[ReplyModel] = []
    @State var isToast = false
    @State var toastMessage = ""
    @State var isLoading = false
    @State var isNSFWDic:[ReplyModel:Bool] = [:]
    private func makeReplyView(reply:ReplyModel)-> some View {
        Group {
            if reply.documentId.isEmpty {
                Button {
                    let idx = replys.firstIndex(of: reply)!
                    FirestoreHelper.Reply.likeToggle(replyId: reply.id) { isLike, error in
                        if isLike == false {
                            replys.remove(at: idx)
                            loadData()
                        }
                    }
                } label : {
                    Text("deleted reply message").font(Font.subheadline).foregroundColor(Color.k_weakText).padding(20)
                }
            } else {
                NavigationLink {
                    PixelArtDetailView(id: reply.documentId, showProfile: true, focusedReply: reply)
                } label: {
                    HStack {
                        VStack {
                            FSImageView(imageRefId: reply.imageRefId, placeholder: .imagePlaceHolder, isNSFW: isNSFWDic[reply] == true)
                                .frame(width: 50, height: 50, alignment: .center)
                            Spacer()
                        }
                        VStack {
                            HStack {
                                reply.updateDtText.font(.system(size: 10)).foregroundColor(.gray)
                                Spacer()
                            }
                            ZStack {
                                Image(reply.uid == reply.documentsUid ? "bubble_purple" : "bubble")
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

                                HStack {
                                    Text(reply.message)
                                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 20))
                                        .font(.subheadline)
                                        .foregroundColor(Color.k_normalText)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
//                        if listMode == .내_게시글에_달린_댓글 || listMode == .내가_좋아요한_댓글 {
                            VStack {
                                Spacer()
                                SimplePeopleView(uid: reply.uid, size:40)
                                    .frame(maxWidth:50)
                            }
//                        }
                    }
                }
            }
        }
    }
    var body: some View {
        LazyVStack {
            BannerAdView(sizeType: .GADAdSizeBanner)
                .padding(.top,20).padding(.bottom,20)
            if isLoading {
            }
            else if replys.count == 0 {
                Text("empty reply list message")
                    .font(.subheadline)
                    .foregroundColor(Color.k_weakText)
            }
            ForEach(replys, id:\.self) { reply in
                makeReplyView(reply: reply)
                    .onAppear {
                        if reply == replys.last && replys.count % (isLimited ? Consts.profileReplyLimit : Consts.timelineLoadReplyLimit) == 0 {
                            loadData()
                        }
                        if let isNSFW = SharedStageModel.findBy(id: reply.documentId)?.isNSFW {
                            isNSFWDic[reply] = isNSFW
                        } else {
                            SharedStageModel.findBy(id: reply.documentId) { isDeleted, error in
                                if isDeleted == false {
                                    if let isNSFW = SharedStageModel.findBy(id: reply.documentId)?.isNSFW {
                                        isNSFWDic[reply] = isNSFW
                                    }
                                }
                            }
                        }
                    }
                               
            }
            
            if isLimited && replys.count % (isLimited ? Consts.profileReplyLimit : Consts.timelineLoadReplyLimit) == 0 && replys.count > 0 {
                NavigationLink {
                    ReplyListFullView(uid: uid, listMode: listMode)
                } label: {
                    Text("more title")
                }
            }
        }.onAppear {
            loadData()
        }
        .toast(message: toastMessage, isShowing: $isToast, duration: 4)
    }
    
    private func loadData() {
        isLoading = true
        switch listMode {
        case .내가_쓴_댓글:
            FirestoreHelper.Reply.getReplys(uid: uid, replys: isLimited ? nil : replys) { result, error in
                withAnimation(.easeInOut) {
                    isLoading = false
                    appendData(result: result)
                }
                toastMessage = error?.localizedDescription ?? ""
                isToast = error != nil
            }
        case .내_게시글에_달린_댓글:
            FirestoreHelper.Reply.getReplysToMe(uid: uid, replys: isLimited ? nil : replys) { result, error in
                withAnimation(.easeInOut) {
                    isLoading = false
                    appendData(result: result)
                }
                toastMessage = error?.localizedDescription ?? ""
                isToast = error != nil
            }
        case .내가_좋아요한_댓글:
            FirestoreHelper.Reply.getLikeReplyList(uid: uid, replys: isLimited ? nil : replys) { result, error in
                withAnimation(.easeInOut) {
                    isLoading = false
                    appendData(result: result)
                }
                toastMessage = error?.localizedDescription ?? ""
                isToast = error != nil
            }
        }
    }
    
    private func appendData(result:[ReplyModel]) {
        if isLimited {
            replys = result
        } else {
            for reply in result {
                if replys.firstIndex(of: reply) == nil {
                    replys.append(reply)
                }
            }
        }
    }
}


struct ReplyListFullView : View {
    let uid:String
    let listMode: ReplyListView.ListMode
    private var navigationTitle:Text {
        switch listMode {
        case .내가_좋아요한_댓글:
            return Text("profile view replys my like")
        case .내가_쓴_댓글:
            return Text("reply written by")
        case .내_게시글에_달린_댓글:
            return Text("received reply")
        }
    }
    var body : some View {
        ScrollView {
            ReplyListView(uid: uid, isLimited: false, listMode: listMode)
                .navigationBarTitle(navigationTitle)
        }
    }
}
