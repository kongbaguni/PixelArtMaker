//
//  PixelArtDetailView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/03.
//

import SwiftUI
import RealmSwift
import SDWebImageSwiftUI
import Alamofire

struct PixelArtDetailView: View {
    enum AlertType {
        case 댓글삭제
    }
    let pid:String
    var model:SharedStageModel? {
        return try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: pid)
    }
    @State var isProfileImage = false
    @State var tmodel:SharedStageModel.ThreadSafeModel? = nil
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var profileModel:ProfileModel? = nil
    @State var isMyLike:Bool = false
    @State var likeCount:Int = 0
    let googleAd = GoogleAd()
    let isShowProfile:Bool
    let isForceUpdate:Bool
    let focusedReply:ReplyModel?
    @State var isShowAlert = false
    @State var alertType:AlertType? = nil
    
    @State var willDeleteReply:ReplyModel? = nil
    
    @State var replyText = ""
    @State var replys:[ReplyModel] = []
    @Namespace var bottomID
    @FocusState var isFocusedReplyInput
    
    init(id:String, showProfile:Bool, forceUpdate:Bool = false, focusedReply:ReplyModel? = nil ) {
        pid = id
        isShowProfile = showProfile
        isForceUpdate = forceUpdate
        self.focusedReply = focusedReply
    }
    private func toggleLike() {
        model?.likeToggle(complete: {isMyLike, error in
            let newModel = model
            if let err = error {
                toastMessage = err.localizedDescription
                isShowToast = true
            } else {
                self.isMyLike = isMyLike
                self.likeCount = newModel?.likeCount ?? 0
                print("like toggle : \(isMyLike)")
            }
        })
    }
    private func makeImageView(imageSize:CGFloat)->some View {
        VStack {
            if let m = tmodel {
                if let imgUrl = m.imageURL {
                    Button {
                        toggleLike()
                    } label: {
                        WebImage(url:imgUrl)
                            .placeholder(.imagePlaceHolder.resizable())
                            .resizable()
                            .frame(width: imageSize, height: imageSize, alignment: .center)
                        
                    }
                }
                
            }
        }.padding(10)
    }
    
    private func makeInfomationView()-> some View {
        VStack {
            LabelTextView(label: "id", text: pid)
            if let m = tmodel {
                LabelTextView(label: "reg dt", text: m.regDt.formatted(date: .long, time: .standard))
                LabelTextView(label: "update dt", text: m.updateDt.formatted(date: .long, time: .standard))
            }
        }
    }
    
    private func makeButtonsView()-> some View {
        VStack {
            Button {
                toggleLike()
            } label: {
                HStack {
                    Image(isMyLike ? "heart_red" : "heart_gray")
                    Text(likeCount.formatted(.number))
                    Text("like list")
                }
            }
            if let m = model {
                if m.likeUserIdsSet.count > 0 {
                    LikePeopleShortListView(uids:m.likeUserIdsSet.sorted())
                }
            }
            if let m = tmodel {
                if m.uid == AuthManager.shared.userId && isProfileImage == false  {
                    Button {
                        ProfileModel.findBy(uid: m.uid)?.updatePhoto(photoURL: m.imageURL.absoluteString, complete: { error in
                            isProfileImage = true
                            toastMessage = error?.localizedDescription ?? ""
                            isShowToast = error != nil
                        })
                    } label : {
                        OrangeTextView(image: Image(systemName: "person.crop.circle"), text: Text("Set as Profile Image"))
                    }
                }
                
                if let img = m.imageURL {
                    Button {
                        googleAd.showAd { isSucess in
                            if isSucess {
                                share(items: [img])
                            }
                        }
                        
                    } label: {
                        OrangeTextView(image: Image(systemName: "square.and.arrow.up"), text: Text("share"))
                    }
                }
            }
        }
    }
    
    func makeProfileView(landScape:Bool)->some View {
        Group {
            if let m = tmodel {
                if isShowProfile {
                    ProfileView(uid: m.uid, haveArtList: false, landScape: landScape)
                }
            }
        }
    }
    
    func makeReplyTextView(scrollViewPrxy:ScrollViewProxy) -> some View {
        VStack {
            HStack {
                TextEditor(text: $replyText)
                    .focused($isFocusedReplyInput)
                    .border(Color.k_normalText, width: 1)
                    .onChange(of: isFocusedReplyInput) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                            withAnimation(.easeInOut) {
                                scrollViewPrxy.scrollTo(bottomID, anchor: .bottom)
                            }
                        }
                    }
                Button {
                    if replyText.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").isEmpty {
                        replyText = ""
                        return
                    }
                    replyText = replyText.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                    guard let model = model else {
                        return
                    }
                    
                    let reply = ReplyModel(documentId: model.id,
                                           documentsUid: model.uid,
                                           message: replyText,
                                           imageURL: model.imageUrl)
                    ReplyManager.shared.addReply(replyModel: reply) { error in
                        if error == nil {
                            isFocusedReplyInput = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                                withAnimation (.easeInOut){
                                    replyText = ""
                                    replys.append(reply)
                                    scrollViewPrxy.scrollTo(bottomID, anchor: .bottom)
                                }
                            }
                        }
                        toastMessage = error?.localizedDescription ?? ""
                        isShowToast = error != nil
                        
                    }
                } label : {
                    OrangeTextView(Text("write reply button title"))
                }
            }
            .padding(.leading,10).padding(.trailing,10)
            .onAppear {
                if let reply = focusedReply {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        withAnimation (.easeInOut){
                            scrollViewPrxy.scrollTo(reply,anchor: .bottom)
                        }
                    }
                }
                
            }
            Spacer().frame(height:10).id(bottomID)
        }
    }
    
    private func replyListProfileView(reply:ReplyModel)-> some View {
        VStack {
            Spacer()
            NavigationLink {
                ProfileView(uid: reply.uid, haveArtList: true)
            } label: {
                SimplePeopleView(uid: reply.uid, isSmall: true)
                    .frame(width: 50, height: 50, alignment: .leading)
            }
        }
    }
    private func replyListReplyView(reply:ReplyModel) -> some View {
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
                } else {
                    Text(reply.message)
                        .padding(10)
                        .padding(.leading,20)
                        .foregroundColor(focusedReply == reply ? .K_boldText : .k_normalText)

                }
                Spacer()
            }
        }
    }
    
    private func replyListUpdateDtView(reply:ReplyModel) ->  some View {
        HStack {
            if reply.uid == AuthManager.shared.userId {
                Spacer()
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
    
    func makeReplyListView() -> some View {
        LazyVStack {
            ForEach(replys, id:\.self) { reply in
                VStack {
                    if reply.uid == AuthManager.shared.userId {
                        HStack {
                            Spacer()
                            replyListReplyView(reply: reply)
                            replyListProfileView(reply: reply)
                                .padding(.trailing, 10)
                        }
                        replyListUpdateDtView(reply: reply)
                            .padding(.trailing, 10)
                    } else {
                        HStack {
                            replyListProfileView(reply: reply)
                                .padding(.leading, 10)
                            replyListReplyView(reply: reply)
                            Spacer()
                        }
                        replyListUpdateDtView(reply: reply)
                            .padding(.leading, 10)
                    }
                    
                }
            }
        }
    }
    
    
    var body: some View {
        Group {
            if tmodel != nil {
                GeometryReader { geomentry in
                    ScrollViewReader { proxy in
                        if geomentry.size.width < geomentry.size.height || geomentry.size.width < 400 {
                            ScrollView {
                                makeProfileView(landScape: false).frame(height:120)
                                makeImageView(imageSize: geomentry.size.width - 20)
                                makeInfomationView().frame(width: geomentry.size.width - 20)
                                makeButtonsView().padding(10)
                                
                                makeReplyListView()
                                makeReplyTextView(scrollViewPrxy: proxy)
                            }
                        } else {
                            HStack {
                                if isShowProfile {
                                    makeProfileView(landScape: true).frame(width:200)
                                }
                                ScrollView {
                                    makeImageView(imageSize: isShowProfile ? 250 : 450)
                                }
                                ScrollView {
                                    makeInfomationView()
                                        .frame(width:geomentry.size.width > 470 ? geomentry.size.width - 470 : 100)
                                        .padding(.top, 10)
                                    makeButtonsView()
                                    makeReplyListView()
                                    makeReplyTextView(scrollViewPrxy: proxy)
                                }
                            }
                        }
                    }
                    
                }
            }
            else {
                Text("loading")
            }
        }
        .alert(isPresented: $isShowAlert, content: {
            switch alertType {
            case .댓글삭제:
                return Alert(title: Text("reply delete title"),
                             message: Text("reply delete message"),
                             primaryButton: .default(
                                Text("reply delete confirm"), action : {
                                    if let reply = willDeleteReply {
                                        ReplyManager.shared.deleteReply(id: reply.id) { error in
                                            if error == nil {
                                                withAnimation(.easeInOut) {
                                                    if let idx = replys.firstIndex(of: reply) {
                                                        replys.remove(at: idx)
                                                    }
                                                }
                                            }
                                            else {
                                                toastMessage = error!.localizedDescription
                                                isShowToast = true
                                            }
                                        }
                                    }
                                }
                             ), secondaryButton: .cancel())
            default:
                return Alert(title:Text(""))
            }
        })
        
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
        .navigationTitle(Text(pid))
        .onAppear {
            print(pid)
            if model == nil || isForceUpdate {
                SharedStageModel.findBy(id: pid) { error in
                    load()
                }
            } else {
                load()
            }
            if let id = model?.id {
                ReplyManager.shared.getReplys(documentId: id, limit:0) { result, error in
                    replys = result
                    toastMessage = error?.localizedDescription ?? ""
                    isShowToast = error != nil                        
                }
            }
            
        }
        
    }

    private func load() {
        if let model = model {
            tmodel = model.threadSafeModel
            isMyLike = model.isMyLike
            likeCount = model.likeCount
            isProfileImage = model.imageUrl == ProfileModel.findBy(uid: model.uid)?.profileURL
        }
        
    }

}

struct PixelArtDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PixelArtDetailView(id:"", showProfile: false, forceUpdate: false)
    }
}
