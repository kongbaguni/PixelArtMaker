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
import ActivityView


struct PixelArtDetailView: View {
    enum AlertType {
        case 댓글삭제
        case error
    }
    let pid:String
    
    var model:SharedStageModel? {
        return try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: pid)
    }
    
    @State var viewCount = 0
    @State var isProfileImage = false
    @State var tmodel:SharedStageModel.ThreadSafeModel? = nil
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var profileModel:ProfileModel? = nil
    @State var isMyLike:Bool = false
    var likeCount:Int {
        return likeUids.count
    }
    let googleAd = GoogleAd()
    
    let isShowProfile:Bool
    let isForceUpdate:Bool
    let focusedReply:ReplyModel?
    @State var isShowAlert = false
    @State var alertType:AlertType? = nil
    
    @State var willDeleteReply:ReplyModel? = nil
    
    @State var replyText = ""
    @State var replys:[ReplyModel] = []
    @State var likeUids:[String] = []
    @State var isDeleted = false
    @Namespace var bottomID
    @FocusState var isFocusedReplyInput
    @State var activityItem:ActivityItem? = nil
    
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isShowAlert = true
                alertType = .error
            }
        }
    }

    init(id:String, showProfile:Bool, forceUpdate:Bool = false, focusedReply:ReplyModel? = nil ) {
        pid = id
        isShowProfile = showProfile
        isForceUpdate = forceUpdate
        self.focusedReply = focusedReply
    }
    
    init(reply:ReplyModel) {
        pid = reply.documentId
        isShowProfile = true
        isForceUpdate = true
        focusedReply = reply
    }
    
    private func toggleLike() {
        FirestoreHelper.PublicArticle.toggleArticleLike(documentId: pid, imageRefId: model?.documentId ?? "") { isLike, uids, error in
            print("toggle like \(isLike), \(likeUids) \(likeUids.count)")
            model?.likeUpdate(isMyLike: isLike, likeUids: likeUids, complete: { error in
                if let err = error {
                    toastMessage = err.localizedDescription
                    isShowToast = true
                } else {
                    self.isMyLike = isLike
                    self.likeUids = likeUids
                    print("like toggle : \(isMyLike)")
                }
            })
        }
    }
    private func makeImageView(imageSize:CGFloat)->some View {
        VStack {
            Button {
                toggleLike()
            } label: {
                if isDeleted {
                    ZStack {
                        Image.errorImage
                            .background(.gray)
                            .opacity(0.5)
                        Text("deleted by user message").font(.headline).foregroundColor(.white)
                    }.frame(width: imageSize, height: imageSize, alignment: .center)
                } else if let m = tmodel {
                    FSImageView(imageRefId: m.documentId, placeholder: .imagePlaceHolder, isNSFW: m.isNSFW, isNSFWUnlock: true)
                        .frame(width: imageSize, height: imageSize, alignment: .center)
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
                LabelTextView(label: "view count", text: "\(viewCount)")
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
            if likeUids.count > 0 {
                LikePeopleShortListView(uids:likeUids)
            }
            if let m = tmodel {
                if m.uid == AuthManager.shared.userId
                    && isProfileImage == false
                    && model?.deleted == false
                    && AuthManager.shared.auth.currentUser?.isAnonymous == false
                    && model?.isNSFW == false 
                {
                    Button {
                        FirestoreHelper.Profile.updatePhoto(photoRefId: m.documentId) { error in
                            isProfileImage = true
                            toastMessage = error?.localizedDescription ?? ""
                            isShowToast = error != nil
                        }
                    } label : {
                        OrangeTextView(image: Image(systemName: "person.crop.circle"), text: Text("Set as Profile Image"))
                    }
                }
                
                Button {
                    FirebaseStorageHelper.shared.getDownloadURL(id: m.documentId) { url, error in
                        self.error = error
                        if let url = url {
                            googleAd.showAd { error in
                                self.error = error
                                if error == nil {
                                    activityItem = .init(itemsArray: [url])
                                }
                            }
                        }
                    }
                    
                } label: {
                    OrangeTextView(image: Image(systemName: "square.and.arrow.up"), text: Text("share"))
                }.activitySheet($activityItem)
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
                                           imageRefId: model.documentId)
                    FirestoreHelper.Reply.add(replyModel: reply) { error in
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
    
    
        
    
    func makeReplyListView() -> some View {
        LazyVStack {
            ForEach(replys, id:\.self) { reply in
                ReplyView(
                    reply: reply,
                    focusedReply: focusedReply,
                    pid: pid,
                    alertType: $alertType,
                    isShowAlert: $isShowAlert,
                    willDeleteReply: $willDeleteReply)
            }
        }
    }
    
    
    var body: some View {
            GeometryReader { geomentry in
                ScrollViewReader { proxy in
                    if geomentry.size.width < geomentry.size.height || geomentry.size.width < 400 {
                        ScrollView {
                            makeProfileView(landScape: false).frame(height:120)
                            makeImageView(imageSize: geomentry.size.width - 20)
                            makeInfomationView().frame(width: geomentry.size.width - 20)
                            NativeAdView().padding(.top,20).padding(.bottom,10)
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
                                NativeAdView().padding(.top,20).padding(.bottom,10)
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
        .alert(isPresented: $isShowAlert, content: {
            switch alertType {
            case .error:
                return .init(title: .init("alert"),
                             message: .init(error?.localizedDescription ?? ""))
            case .댓글삭제:
                return Alert(title: Text("reply delete title"),
                             message: Text("reply delete message"),
                             primaryButton: .default(
                                Text("reply delete confirm"), action : {
                                    if let reply = willDeleteReply {
                                        FirestoreHelper.Reply.delete(id: reply.id) { error in
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
                SharedStageModel.findBy(id: pid) { isDeleted ,error in
                    if error == nil {
                        load()
                    }
                    toastMessage = error?.localizedDescription ?? ""
                    isShowToast = error != nil
                    if isDeleted {
                        self.isDeleted = true
                    }
                }
            } else {
                load()
            }
            FirestoreHelper.Reply.getReplys(documentId: pid, limit:0) { result, error in
                replys = result
                toastMessage = error?.localizedDescription ?? ""
                isShowToast = error != nil
            }
            FirestoreHelper.Timeline.read(articleId: pid, isRead: true) { count, error in
                viewCount = count
                toastMessage = error?.localizedDescription ?? ""
                isShowToast = error != nil
            }
            
            FirestoreHelper.PublicArticle.getLikePeopleIds(documentId: pid) { uids, error in
                likeUids = uids
                toastMessage = error?.localizedDescription ?? ""
                isShowToast = error != nil
                isMyLike = uids.firstIndex(of: AuthManager.shared.userId!) != nil
            }
            NotificationCenter.default.addObserver(forName: .likeArticleDataDidChange, object: nil, queue: nil) { noti in
                if let ids = noti.userInfo?["likePeopleUids"] as? [String] {
                    withAnimation {
                        self.likeUids = ids
                    }
                }
            }
            
        }
        
    }

    private func load() {
        if let model = model {
            tmodel = model.threadSafeModel
            isProfileImage = model.documentId == ProfileModel.findBy(uid: model.uid)?.profileImageRefId
        }
    }

}

struct PixelArtDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PixelArtDetailView(id:"", showProfile: false, forceUpdate: false)
    }
}
