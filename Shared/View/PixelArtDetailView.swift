//
//  PixelArtDetailView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/03.
//

import SwiftUI
import RealmSwift

struct PixelArtDetailView: View {
    let pid:String
    var model:SharedStageModel? {
        return try! Realm().object(ofType: SharedStageModel.self, forPrimaryKey: pid)
    }
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var profileModel:ProfileModel? = nil
    @State var isMyLike:Bool = false
    @State var likeCount:Int = 0
    let googleAd = GoogleAd()
    
    init(id:String) {
        pid = id
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
            if let m = model {
                ProfileView(m.uid)
                if let img = m.imageValue {
                    Button {
                        toggleLike()
                    } label: {
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: screenBounds.width - 20, height: screenBounds.width - 20, alignment: .center)

                    }
                }
                VStack {
                    LabelTextView(label: "id", text: pid)
                    LabelTextView(label: "reg dt", text: m.regDate.formatted(date: .long, time: .standard))
                    LabelTextView(label: "update dt", text: m.updateDate.formatted(date: .long, time: .standard))
                }.padding(10)

                HStack {
                    Button {
                        toggleLike()
                    } label: {
                        HStack {
                            if isMyLike {
                                Image("heart_red")
                            } else {
                                Image("heart_gray")
                            }
                            Text("\(likeCount)")
                        }
                    }
                    
                    if let img = m.imageValue?.pngData() {
                        Button {
                            googleAd.showAd { isSucess in
                                if isSucess {
                                    share(items: [img])
                                }
                            }
                            
                        } label: {
                            OrangeTextView(Text("share"))
                        }
                    }
                }

            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
        .navigationTitle(Text(pid))
        .onAppear {
            print(pid)
            if let uid = model?.uid {
                ProfileModel.findBy(uid: uid) { error in
                    profileModel = ProfileModel.findBy(uid: uid)
                }
            }
            isMyLike = model?.isMyLike ?? false
            likeCount = model?.likeCount ?? 0

        }
    }
}

struct PixelArtDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PixelArtDetailView(id:"")
    }
}
