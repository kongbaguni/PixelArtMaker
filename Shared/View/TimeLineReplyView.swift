//
//  TimeLineReplyView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/05/01.
//

import SwiftUI

struct TimeLineReplyView: View {
    
    @State var replys:[ReplyModel] = []
    
    var listView : some View {
        LazyVStack {
            ForEach(replys, id:\.self) { reply in
                NavigationLink {
                    PixelArtDetailView(reply: reply)
                } label: {
                    HStack {
                        if reply.uid == AuthManager.shared.userId {
                            FSImageView(imageRefId: reply.imageRefId, placeholder: .imagePlaceHolder)
                                .frame(width: 50, height: 50, alignment: .leading)
                            ZStack {
                                Image(reply.documentModel?.uid == reply.uid ? "bubble_purple" : "bubble")
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                Text(reply.message).font(.subheadline).foregroundColor(.k_weakText)
                                    .padding(5)
                            }
                            SimplePeopleView(uid: reply.uid, size: 40).frame(width: 50)

                        } else {
                            SimplePeopleView(uid: reply.uid, size: 40).frame(width: 50)
                            ZStack {
                                Image(reply.documentModel?.uid == reply.uid ? "bubble_purple" : "bubble")
                                Text(reply.message).font(.subheadline).foregroundColor(.k_weakText)
                                    .padding(5)
                            }
                            FSImageView(imageRefId: reply.imageRefId, placeholder: .imagePlaceHolder)
                                .frame(width: 50, height: 50, alignment: .leading)
                        }
                    }
                    
                }
                .onAppear {
                    if reply == replys.last {
                        FirestoreHelper.getReplyTopicList(indexReply: reply, isLast: true) { replys, error in
                            for reply in replys {
                                if self.replys.firstIndex(of: reply) == nil {
                                    self.replys.append(reply)
                                }
                            }
                        }
                    }
                    if reply == replys.first {
                        FirestoreHelper.getReplyTopicList(indexReply: reply, isLast: false) { replys, error in
                            for reply in replys.reversed() {
                                if self.replys.firstIndex(of: reply) == nil {
                                    self.replys.insert(reply, at: 0)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            ScrollView {
                listView
            }
        }.onAppear {
            if replys.count == 0 {
                FirestoreHelper.getReplyTopicList(indexReply:nil, isLast: false) { replys, error in
                    self.replys = replys
                }
            }
        }
    }
}

struct TimeLineReplyView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineReplyView()
    }
}
