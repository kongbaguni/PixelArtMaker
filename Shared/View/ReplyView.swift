//
//  ReplyView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/25.
//

import SwiftUI
import RealmSwift

struct ReplyView: View {
    
    let reply:ReplyModel
    let focusedReply:ReplyModel?
    /** 공유된 그림파일의 아이디*/
    let pid:String
    
    @Binding var alertType:PixelArtDetailView.AlertType?
    @Binding var isShowAlert:Bool
    @Binding var willDeleteReply:ReplyModel?
    @State var isMyLike = false
    @State var likeUids:[String] = []
    @State var toastMessage:String = ""
    @State var isShowToast = false
    var model:SharedStageModel? {
        return try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: pid)
    }

    private var replyView: some View {
        ZStack {
            if reply.uid == AuthManager.shared.userId {
                Image(reply.uid == model?.uid ? "bubble_purple" :"bubble")
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                Image(reply.uid == model?.uid ? "bubble_purple" :"bubble")
            }
            HStack {
                if reply.uid == AuthManager.shared.userId {
                    Text(reply.message)
                        .padding(10)
                        .padding(.trailing,20)
                        .foregroundColor(focusedReply == reply ? .K_boldText : .k_normalText)
                        .multilineTextAlignment(.leading)

                } else {
                    Text(reply.message)
                        .padding(10)
                        .padding(.leading,20)
                        .foregroundColor(focusedReply == reply ? .K_boldText : .k_normalText)
                        .multilineTextAlignment(.leading)


                }
                Spacer()
            }
        }
    }
    
    private var profileView : some View {
        VStack {
            Spacer()
            NavigationLink {
                ProfileView(uid: reply.uid, haveArtList: true)
                    .navigationTitle(Text(ProfileModel.findBy(uid: reply.uid)?.nickname ?? reply.uid))
            } label: {
                SimplePeopleView(uid: reply.uid, size:40)
                    .frame(width: 50, height: 50, alignment: .leading)
            }
        }
    }
    
    
    private var updateDtView : some View {
        HStack {
            if reply.uid == AuthManager.shared.userId {
                Spacer()
            }
            Button {
                FirestoreHelper.likeToggle(replyId: reply.id) { isLike, error1 in
                    isMyLike = isLike
                    FirestoreHelper.getLikePeopleList(replyId: reply.id) { uids, error2 in
                        self.likeUids = uids
                        toastMessage = error1?.localizedDescription ?? error2?.localizedDescription ?? ""
                        isShowToast = (error1 ?? error2) != nil
                    }
                }
            } label : {
                HStack {
                    Image( isMyLike ? "heart_red" : "heart_gray")
                    Text("like list")
                }
            }
            
            if likeUids.count > 0 {
                NavigationLink {
                    likePeopleFullListView(uids: likeUids)
                        .navigationTitle(Text("like peoples"))
                } label: {
                    Text("\(likeUids.count)")
                    Text("like people count title")
                }
            }

            reply.updateDtText.font(.system(size: 10))
            if reply.uid == AuthManager.shared.userId {
                Button {
                    alertType = .댓글삭제
                    isShowAlert = true
                    willDeleteReply = reply
                } label : {
                    Text("delete reply")
                }.padding(.trailing, 10)
            }
            if reply.uid != AuthManager.shared.userId {
                Spacer()
            }
        }
    }
    
    var body: some View {
        VStack {
            if reply.uid == AuthManager.shared.userId {
                HStack {
                    Spacer()
                    replyView
                    profileView
                        .padding(.trailing, 10)
                }
                updateDtView
                    .padding(.trailing, 10)
            } else {
                HStack {
                    profileView
                        .padding(.leading, 10)
                    replyView
                    Spacer()
                }
                updateDtView
                    .padding(.leading, 10)
            }            
        }
        .onAppear {
            FirestoreHelper.getLikePeopleList(replyId: reply.id) { uids, error in
                likeUids = uids
                self.isMyLike = uids.firstIndex(of: AuthManager.shared.userId!) != nil
                
                toastMessage = error?.localizedDescription ?? ""
                isShowToast = error != nil
            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
    }
}
