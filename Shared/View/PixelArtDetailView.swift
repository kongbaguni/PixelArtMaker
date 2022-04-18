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
    
    init(id:String, showProfile:Bool, forceUpdate:Bool = false) {
        pid = id
        isShowProfile = showProfile
        isForceUpdate = forceUpdate
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
    
    var body: some View {
        Group {
            if tmodel != nil {
                GeometryReader { geomentry in
                    if geomentry.size.width < geomentry.size.height {
                        ScrollView {
                            makeProfileView(landScape: false).frame(height:120)
                            makeImageView(imageSize: geomentry.size.width - 20)
                            makeInfomationView().frame(width: geomentry.size.width - 20)
                            makeButtonsView().padding(10)
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
                            }
                        }
                        
                    }
                }
            }
            else {
                Text("loading")
            }
        }

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
