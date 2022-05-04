//
//  TimeLineReplyView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/05/01.
//

import SwiftUI

struct TimeLineReplyView: View {
    
    @State var replys:[ReplyModel] = []
    @State var isLoading = false
    @State var isNSFWDic:[ReplyModel:Bool] = [:]
    
    private func makeReplyView(reply:ReplyModel) -> some View {
        NavigationLink {
            PixelArtDetailView(reply: reply)
        } label: {
            HStack {
                if reply.uid == AuthManager.shared.userId {
                    VStack {
                        FSImageView(imageRefId: reply.imageRefId, placeholder: .imagePlaceHolder, isNSFW: isNSFWDic[reply] == true)
                            .frame(width: 80, height: 80, alignment: .leading)
                        Spacer()
                    }
                    ZStack {
                        Image(reply.documentModel?.uid == reply.uid ? "bubble_purple" : "bubble")
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        HStack {
                            Text(reply.message).font(.subheadline).foregroundColor(.k_weakText)
                                .padding(5)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 10)
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                        SimplePeopleView(uid: reply.uid, size: 40).frame(width: 50)
                    }

                } else {
                    VStack {
                        Spacer()
                        SimplePeopleView(uid: reply.uid, size: 40).frame(width: 50)
                    }
                    ZStack {
                        Image(reply.documentModel?.uid == reply.uid ? "bubble_purple" : "bubble")
                        HStack {
                            Text(reply.message).font(.subheadline).foregroundColor(.k_weakText)
                                .padding(5)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 20)
                            Spacer()
                        }
                    }
                    VStack {
                        FSImageView(imageRefId: reply.imageRefId, placeholder: .imagePlaceHolder, isNSFW: isNSFWDic[reply] == true)
                            .frame(width: 80, height: 80, alignment: .leading)
                        Spacer()
                    }
                }
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                if reply == replys.last {
                    FirestoreHelper.Reply.getReplyTopicList(indexReply: reply, isLast: true) { replys, error in
                        for reply in replys {
                            if self.replys.firstIndex(of: reply) == nil {
                                self.replys.append(reply)
                            }
                        }
                    }
                }
                if reply == replys.first {
                    FirestoreHelper.Reply.getReplyTopicList(indexReply: reply, isLast: false) { replys, error in
                        for reply in replys.reversed() {
                            if self.replys.firstIndex(of: reply) == nil {
                                self.replys.insert(reply, at: 0)
                            }
                        }
                    }
                }
                
                if let isNSFW = SharedStageModel.findBy(id: reply.documentId)?.isNSFW {
                    isNSFWDic[reply] = isNSFW
                } else {
                    SharedStageModel.findBy(id: reply.documentId) { isDeleted, error in
                        if !isDeleted {
                            if let isNSFW = SharedStageModel.findBy(id: reply.documentId)?.isNSFW {
                                isNSFWDic[reply] = isNSFW
                            }
                        }
                    }
                }
            }
        }
    }
    
    var listView : some View {
        LazyVStack {
            ForEach(replys, id:\.self) { reply in
                makeReplyView(reply: reply)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            if replys.count == 0 {
                Group {
                    if isLoading {
                        VStack {
                            ActivityIndicator(isAnimating: $isLoading, style: .large)
                            Text("reply loading").font(.subheadline).foregroundColor(.k_weakText)
                        }
                    } else {
                        Text("empty reply list message").font(.subheadline).foregroundColor(.k_weakText)
                    }
                }.frame(width:geomentry.size.width, height:geomentry.size.height)
            } else {
                ScrollView {
                    listView
                }
            }
        }
        .onAppear {
            if replys.count == 0 {
                isLoading = true
                FirestoreHelper.Reply.getReplyTopicList(indexReply:nil, isLast: false) { replys, error in
                    isLoading = false
                    self.replys = replys
                }
            }
            NotificationCenter.default.addObserver(forName: .replyDidDeleted, object: nil, queue: nil) { noti in
                if let id = noti.object as? String {
                    if let reply = replys.filter({ model in
                        return model.id == id
                    }).first {
                        if let idx = replys.firstIndex(of: reply) {
                            replys.remove(at: idx)
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("menu public load title"))
    }
}

struct TimeLineReplyView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineReplyView()
    }
}
