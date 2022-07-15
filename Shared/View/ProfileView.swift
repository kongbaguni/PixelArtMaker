//
//  ProfileView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/02.
//

import SwiftUI
import SDWebImageSwiftUI
import RealmSwift
struct ProfileView: View {
    enum AlertType {
        case normal
        case leave
    }
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let uid:String
    let haveArtList:Bool
    let editabel:Bool
    let landScape:Bool?
    var isAnonymous:Bool {
        if ProfileModel.findBy(uid: uid) == nil {
            return true
        }
        if editabel && AuthManager.shared.auth.currentUser?.isAnonymous == true {
            return true
        }
        return false
    }
    
    init(uid:String, haveArtList:Bool, editable:Bool = false, landScape:Bool? = nil) {
        self.uid = uid
        self.haveArtList = haveArtList
        self.editabel = editable
        self.landScape = landScape
    }
    @State var isAlert = false
    @State var alertType:AlertType = .normal
    @State var alertTitle:Text? = nil
    @State var alertMessage:Text? = nil
    
    @State var toastMessage:String = ""
    @State var isToast = false
    @State var nickname:String = ""
    @State var introduce:String = ""
    @State var imageRefId:String? = nil
    @State var email:String = ""
    
    @State var sharedIds:[String] = []
    /** 탈퇴처리 프로그레스*/
    @State var leaveProgress:(title:Text,completed:Int,total:Int)? = nil
    
    private func makeProfileImageView(size:CGFloat)-> some View {
        VStack {
            if let url = imageRefId {
                FSImageView(imageRefId: url, placeholder: .profilePlaceHolder, error: .profilePlaceHolder)
                    .frame(width: size, height: size, alignment: .center)
            } else {
                Image.profilePlaceHolder
                    .resizable()
                    .frame(width: size, height: size, alignment: .center)
            }
        }
    }
    
    private func mkaeProfileInfomationView(isLandScape:Bool)-> some View {
        VStack {
            if isAnonymous == false {
                HStack {
                    Text("name")
                        .font(.system(size: 10, weight: .heavy, design: .serif))
                        .padding(5)
                    if editabel {
                        TextField("name", text: $nickname)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(nickname)
                            .font(.system(size: 10, weight: .light, design: .serif))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                HStack {
                    Text("profile introduce title")
                        .font(.system(size: 10, weight: .heavy, design: .serif))
                        .padding(5)
                    if editabel {
                        TextEditor(text: $introduce)
                            .border(Color.k_weakText)
                    } else {
                        Text(introduce)
                            .font(.system(size: 10, weight: .light, design: .serif))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            
            if haveArtList == false {
                HStack {
                    NavigationLink {
                        ArtListView(uid: uid,navigationTitle: Text("art list"))
                    } label: {
                        Text("art list")
                            .padding(5)
                            .font(.system(size: 10, weight: .heavy, design: .serif))
                    }

                    NavigationLink  {
                        LikeArtListFullView(uid: uid)
                            .navigationTitle(Text("like art list"))
                        
                    } label: {
                        Text("like art list")
                            .padding(5)
                            .font(.system(size: 10, weight: .heavy, design: .serif))
                    }


                    NavigationLink {
                        ReplyListFullView(uid: uid, listMode: .내가_쓴_댓글).navigationBarTitle("own replys")
                    } label: {
                        Text("own replys")
                            .padding(5)
                            .font(.system(size: 10, weight: .heavy, design: .serif))

                    }
                    Spacer()
                }
                
            }
            Spacer()
        }
    }
    
    private func makeProfileView(isLandscape:Bool)-> some View {
        VStack {
            if isLandscape {
                ScrollView {
                    HStack {
                        makeProfileImageView(size: 200)
                        Spacer()
                    }
                    mkaeProfileInfomationView(isLandScape: isLandscape)
                }
            } else {
                HStack {
                    makeProfileImageView(size: 100)
                    mkaeProfileInfomationView(isLandScape: isLandscape)
                }
            }
            if isAnonymous && editabel {
                HStack {
                    AuthorizationButton(provider: .apple, sizeType: .large, authType: .signup) {
                        AuthManager.shared.upgradeAnonymousWithAppleId { isSucess in
                            if isSucess {
                                FirestoreHelper.Profile.downloadProfile(isCreateDefaultProfile: true) { error in
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                alertMessage = Text("upgrade anoymouse faild message")
                                isAlert = true
                            }
                        }
                    }
                    AuthorizationButton(provider: .google, sizeType: .large, authType: .signup) {
                        AuthManager.shared.upgradeAnonymousWithGoogleId { isSucess in
                            if isSucess {
                                FirestoreHelper.Profile.downloadProfile(isCreateDefaultProfile: true) { error in
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                alertMessage = Text("upgrade anoymouse faild message")
                                isAlert = true
                            }
                        }
                    }
                }
            }
            if editabel && uid == AuthManager.shared.userId && AuthManager.shared.auth.currentUser?.isAnonymous == false {
                VStack {
                    leaveButton
                    if let progress = leaveProgress {
                        KProgressView(total: progress.total, progress: progress.completed, title: progress.title)
                    }
                }
            }
        }
    }
    
    
    private func makeList1(size:CGSize)-> some View {
        ScrollView {
            makeProfileView(isLandscape: false)
            Section(header:Text("profile view public arts")) {
                ArticleListView(uid: uid,
                                gridItems: Utill.makeGridItems(length: 4, screenWidth: size.width),
                                itemSize: Utill.makeItemSize(length: 4, screenWidth: size.width), isLimited: true)
            }.padding(.top, 20)
            
            Section(header:Text("profile view like arts")) {
                LikeArtListView(uid: uid, gridItems: Utill.makeGridItems(length: 4, screenWidth: size.width),
                                itemSize: Utill.makeItemSize(length: 4, screenWidth: size.width), isLimited: true)
                
            }.padding(.top, 20)
            Section(header:Text("profile view replys")) {
                ReplyListView(uid: uid, isLimited: true, listMode:.내가_쓴_댓글)
            }.padding(.top, 20)
            if isAnonymous == false {
                Section(header:Text("profile view replys to me")) {
                    ReplyListView(uid: uid, isLimited: true, listMode:.내_게시글에_달린_댓글)
                }.padding(.top, 20)
            }
            Section(header:Text("profile view replys my like")) {
                ReplyListView(uid: uid, isLimited: true, listMode:.내가_좋아요한_댓글)
            }.padding(.top, 20)
        }
    }
    
    private func makeList2(size:CGSize)-> some View {
        HStack {
            if isAnonymous == false {
                makeProfileView(isLandscape: true)
                    .frame(width:250)
            }
            ScrollView {
                Section(header:Text("profile view public arts")) {
                    ArticleListView(uid: uid,
                                    gridItems: Utill.makeGridItems(length: 6, screenWidth: size.width - size.height - 10),
                                    itemSize: Utill.makeItemSize(length: 6, screenWidth: size.width - size.height - 10), isLimited: true)                            }.padding(.top, 20)

                Section(header:Text("profile view like arts")) {
                    LikeArtListView(uid: uid, gridItems: Utill.makeGridItems(length: 6, screenWidth: size.width - size.height - 10),
                                    itemSize: Utill.makeItemSize(length: 6, screenWidth: size.width - size.height - 10), isLimited:true)
                
                }.padding(.top, 20)
                Section(header:Text("profile view replys")) {
                    ReplyListView(uid: uid, isLimited: true, listMode:.내가_쓴_댓글)
                }.padding(.top, 20)
                if isAnonymous == false {
                    Section(header:Text("profile view replys to me")) {
                        ReplyListView(uid: uid, isLimited: true, listMode:.내_게시글에_달린_댓글)
                    }.padding(.top, 20)
                }
                
                Section(header:Text("profile view replys my like")) {
                    ReplyListView(uid: uid, isLimited: true, listMode:.내가_좋아요한_댓글)
                }.padding(.top, 20)


            }
        }
    }
    
    var leaveButton : some View {
        Button {
            alertType = .leave
            isAlert = true
        } label: {
            Text("leave action title")
                .font(.subheadline)
                .foregroundColor(.red)
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            if haveArtList {
                if geomentry.size.height > geomentry.size.width || geomentry.size.width < 400{
                    makeList1(size: geomentry.size)
                }
                else {
                    makeList2(size: geomentry.size)
                }
            }
            else {
                HStack {
                    makeProfileView(isLandscape: landScape == true)
                }
            }
        }
        .padding(10)
        .onAppear {
            NotificationCenter.default.addObserver(forName: .profileDidUpdated, object: nil, queue: nil) { notification in
                self.loadData()
            }
            loadData()
            if uid.isEmpty == false {
                FirestoreHelper.Profile.findBy(uid: uid) { error in
                    loadData()
                    toastMessage = error?.localizedDescription ?? ""
                    isToast = error != nil
                }
            }
        }
        .toast(message: toastMessage, isShowing: $isToast, duration:4)
        .alert(isPresented: $isAlert) {
            switch alertType {
            case .normal:
                return Alert(title: alertTitle ?? Text("commom alert title"), message: alertMessage, dismissButton: nil)
            case .leave:
                return Alert(title: Text("leave alert title"),
                      message: Text("leave alert message"),
                      primaryButton: .default(Text("leave alert confirm"), action: {
                    AuthManager.shared.leave { progress in
                        leaveProgress = progress
                    } complete: { error in
                        if error != nil {
                            toastMessage = error?.localizedDescription ?? ""
                            isToast = true
                            return
                        }
                        leaveProgress = nil 
                        let size = StageManager.shared.canvasSize
                        StageManager.shared.initStage(canvasSize:size)
                        presentationMode.wrappedValue.dismiss()
                    }
                }), secondaryButton: .cancel())
                      
            }
        }
        .toolbar {
            if editabel && isAnonymous == false {
                Button {
                    FirestoreHelper.Profile.updateProfile(nickname: nickname, introduce:introduce) { error in
                        if error == nil {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            toastMessage = error!.localizedDescription
                            isToast = true
                        }
                    }
                } label : {
                    Text("save")
                }
            }
        }
    }
    
    private func loadData() {
        guard let user = try! Realm().object(ofType: ProfileModel.self, forPrimaryKey: uid) else {
            return
        }
        nickname = user.nickname
        introduce = user.introduce
        imageRefId = user.profileImageRefId
        email = user.email
        
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(uid: "", haveArtList: false)
    }
}
