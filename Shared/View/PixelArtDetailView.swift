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
    
    var body: some View {
        ScrollView {
            if let m = tmodel {
                if isShowProfile {
                    ProfileView(uid: m.uid, haveArtList: false)
                }
                if let imgUrl = m.imageURL {
                    Button {
                        toggleLike()
                    } label: {
                        WebImage(url:imgUrl)
                            .placeholder(.imagePlaceHolder)
                            .resizable()
                            .frame(width: screenBounds.width - 20, height: screenBounds.width - 20, alignment: .center)

                    }
                }
                VStack {
                    LabelTextView(label: "id", text: pid)
                    LabelTextView(label: "reg dt", text: m.regDt.formatted(date: .long, time: .standard))
                    LabelTextView(label: "update dt", text: m.updateDt.formatted(date: .long, time: .standard))
                }.padding(10)

                Button {
                    toggleLike()
                } label: {
                    HStack {
                        Image(isMyLike ? "heart_red" : "heart_gray")
                        Text(likeCount.formatted(.number))
                    }
                }
                
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
