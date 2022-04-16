//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import RealmSwift
import GoogleMobileAds


struct SaveView: View {
    let googleAd = GoogleAd()
    let bannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
    let dim = DimLoadingViewController()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var id:String? = nil
    @State var sharedId:String? = nil
    @State var updateDateTimeFromDb:Date? = nil
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    @State var title:String = ""
    @State var previewImage:Image? = nil
    @State var shareImageDatas:[Data] = []
    
    func updateId() {
        self.id = StageManager.shared.stage?.documentId
        var id:String? {
            if let id = StageManager.shared.stage?.documentId {
                if let model = try! Realm().object(ofType: MyStageModel.self, forPrimaryKey: id) {
                    return model.shareDocumentId.isEmpty ? nil : model.shareDocumentId
                }
            }
            return nil
        }
        sharedId = id

        var updateDate:Date? {
            if let id = StageManager.shared.stage?.documentId {
                if let model = try! Realm().object(ofType: MyStageModel.self, forPrimaryKey: id) {
                    return model.updateDt
                }
            }
            return nil
        }
        updateDateTimeFromDb = updateDate
    }

    private func makePreviewImageView(width:CGFloat)-> some View {
        (previewImage ?? Image.imagePlaceHolder)
            .resizable().frame(width: width - 10, height: width - 10 , alignment: .center)
    }
    
    private func makeButtonList()-> some View {
        Group {
            if let id = self.id {
                HStack {
                    Text("currentId")
                    TagView(Text(id))
                }
                
                if let id = sharedId {
                    HStack {
                        Text("sharedId")
                        NavigationLink {
                            PixelArtDetailView(id: id, showProfile: false, forceUpdate: true)
                        } label: {
                            TagView(Text(id))
                        }

                    }
                }
                
                if let dt = updateDateTimeFromDb {
                    HStack {
                        Text("update dt")
                        Text(dt.formatted(date: .long, time: .standard))
                            .foregroundColor(.gray)
                    }
                }
                 
            }
            HStack {
                //MARK: 기존 파일에 저장
                if StageManager.shared.stage?.documentId != nil && StageManager.shared.stage?.isMyPicture == true {
                    Button {
                        dim.show()
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false, complete: {errorA in
                                if sharedId != nil {
                                    StageManager.shared.sharePublic { errorB in
                                        dim.hide()
                                        isShowToast = errorA != nil || errorB != nil
                                        toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                        updateId()
                                        if errorA == nil && errorB == nil  {
//                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    return
                                }
                                updateId()
                                dim.hide()
//                                presentationMode.wrappedValue.dismiss()
                            })
                        }
                        
                    } label: {
                        OrangeTextView(image: Image(systemName: "icloud.and.arrow.up"), text: .save_to_existing_file)
                    }
                }
                //MARK: 새 파일로 저장
                if StageManager.shared.stage?.documentId == nil || InAppPurchaseModel.isSubscribe {
                    Button {
                        dim.show()
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: true, complete: { error in
                                dim.hide()
                                updateId()
                                toastMessage = error?.localizedDescription ?? ""
                                isShowToast = error != nil
                                if error == nil  {
                                    //                                presentationMode.wrappedValue.dismiss()
                                }
                            })
                        }
                        
                    } label: {
                        OrangeTextView(image: Image(systemName: "icloud.and.arrow.up"), text: .save_as_new_file)
                    }
                }
                
            }
            
            ForEach(shareImageDatas, id:\.self) { img in
                let id = shareImageDatas.firstIndex(of: img)
                Button {
                    googleAd.showAd { isSucess in
                        if isSucess {
                            share(items: [img])
                        }
                    }
                } label: {
                    OrangeTextView(image: Image(systemName: "square.and.arrow.up"), boldText: Text("share"), text: Consts.sizeTitles[id!])
                }

            }
            

            if StageManager.shared.stage?.documentId != nil && sharedId == nil && AuthManager.shared.auth.currentUser?.isAnonymous == false {
                HStack {
                    Button {
                        dim.show()
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false) { errorA in
                                StageManager.shared.sharePublic { errorB in
                                    dim.hide()
                                    toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                    isShowToast = errorA != nil || errorB != nil
                                    updateId()
                                    if errorA == nil && errorB == nil {
//                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                        
                    } label: {
                        OrangeTextView(image: Image(systemName: "shareplay"), text: Text("share public"))
                    }
                }
            }

        }
    }
    var body: some View {
        GeometryReader { geomentry in
            if geomentry.size.height > geomentry.size.width {
                ScrollView {
                    if let id = AuthManager.shared.userId {
                        ProfileView(uid: id, haveArtList: false, landScape: false)
                            .frame(height:120)
                    }
                    
                    makePreviewImageView(width: geomentry.size.width)
                    if InAppPurchaseModel.isSubscribe == false {
                        GoogleAdBannerView(bannerView: bannerView)
                            .frame(width: 320, height: 100, alignment: .center)
                            .padding(.top,10)
                            .padding(.bottom,10)
                    }

                    makeButtonList()
                        .padding(.bottom,10)
                }
            }
            else {
                HStack {
                    if let id = AuthManager.shared.userId {
                        ProfileView(uid: id, haveArtList: false, landScape: true)
                            .frame(width:250)
                    }
                    ScrollView {
                        makePreviewImageView(width: geomentry.size.width - 250)
                        if InAppPurchaseModel.isSubscribe == false {
                            GoogleAdBannerView(bannerView: bannerView)
                                .frame(width: 320, height: 100, alignment: .center)
                                .padding(.top,10)
                                .padding(.bottom,10)
                        }
                        makeButtonList()
                            .padding(.bottom,10)
                    }
                }
            }

        }
        .navigationTitle(Text("save"))
        .onAppear {
            updateId()
            if let stage = StageManager.shared.stage {
                self.colors = stage.layers.map({ model in
                    return model.colors
                })
                backgroundColor = stage.backgroundColor
                title = stage.title ?? ""
                stage.getImage(size: Consts.previewImageSize) { image in
                    previewImage = image
                }
                shareImageDatas.removeAll()
                for size in InAppPurchaseModel.isSubscribe
                        ? Consts.sizes
                        : [Consts.sizes[0],Consts.sizes[1],Consts.sizes[2]] {
                    if let data = stage.makeImageDataValue(size: size) {
                        shareImageDatas.append(data)
                    }
                }
            }
        }
        .onDisappear {
            StageManager.shared.stage?.title = title
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
    }
}

struct SaveView_Previews: PreviewProvider {
    static var previews: some View {
        SaveView()
    }
}
