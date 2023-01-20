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
    
    @State var isShowActionSheet = false
    @State var isPreseneted = false
    
    @State var alertText:Text? = nil
    @State var isShowAlert = false

    @State var isNSFW = false
    
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
        ZStack {
            if StageManager.shared.stage?.backgroundColor.ciColor.alpha ?? 1.0 < 1.0 {
                Image(pixelSize: (width: 16, height: 16),
                      backgroundColor: .clear,
                      size: CGSize(width: width * 3, height: width * 3))?.resizable()
            }
            (previewImage ?? Image.imagePlaceHolder)
                .resizable()
                
        }.frame(width: width - 20, height: width - 20 , alignment: .center)
    }
    
    private var actionSheetButtonsForShareItems:[ActionSheet.Button] {
        var buttons:[ActionSheet.Button] = []
        
        let btn:ActionSheet.Button = .default(Text("all share select title")) {
            googleAd.showAd { isSucess in
                if isSucess {
                    if InAppPurchaseModel.isSubscribe {
                        share(items: shareImageDatas)
                    } else {
                        share(items: [shareImageDatas[0],shareImageDatas[1],shareImageDatas[2]])
                    }
                }
            }
        }
        buttons.append(btn)

        for img in shareImageDatas {
            let id = shareImageDatas.firstIndex(of: img)
            let btn:ActionSheet.Button = .default(Consts.sizeTitles[id!]) {
                googleAd.showAd { isSucess in
                    if isSucess {
                        share(items: [img])
                    }
                }
            }
            buttons.append(btn)
        }

        buttons.append(.cancel())
        return buttons
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
                Toggle("NSFW title", isOn: $isNSFW).onChange(of: isNSFW) { newValue in
                    print(newValue)
                    StageManager.shared.stage?.isNSFW = newValue
                }
                .padding(.leading,20)
                .padding(.trailing,20)
            }

            HStack {
                //MARK: 기존 파일에 저장
                if StageManager.shared.stage?.documentId != nil && StageManager.shared.stage?.isMyPicture == true {
                    Button {
                        dim.show()
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false, isNSFW: isNSFW,complete: {errorA in
                                if sharedId != nil {
                                    StageManager.shared.sharePublic (isNSFW: isNSFW) { errorB in
                                        dim.hide()
                                        isShowToast = errorA != nil || errorB != nil
                                        toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                        updateId()
                                        if errorA == nil && errorB == nil  {
                                            alertText = Text("save view save sucess")
                                            isShowAlert = true
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
                            StageManager.shared.save(asNewForce: true, isNSFW: isNSFW, complete: { error in
                                dim.hide()
                                updateId()
                                toastMessage = error?.localizedDescription ?? ""
                                isShowToast = error != nil
                                if error == nil  {
                                    alertText = Text("save view save sucess")
                                    isShowAlert = true
                                }
                            })
                        }
                        
                    } label: {
                        OrangeTextView(image: Image(systemName: "icloud.and.arrow.up"), text: .save_as_new_file)
                    }
                }
                
            }
            
            Button {
                isShowActionSheet = true
            } label : {
                OrangeTextView(image: Image(systemName: "square.and.arrow.up"), boldText: nil, text: Text("share"))
            }
//            ForEach(shareImageDatas, id:\.self) { img in
//                let id = shareImageDatas.firstIndex(of: img)
//                Button {
//                    googleAd.showAd { isSucess in
//                        if isSucess {
//                            share(items: [img])
//                        }
//                    }
//                } label: {
//                    OrangeTextView(image: Image(systemName: "square.and.arrow.up"), boldText: Text("share"), text: Consts.sizeTitles[id!])
//                }
//
//            }
            

            if StageManager.shared.stage?.documentId != nil && sharedId == nil {
                HStack {
                    Button {
                        dim.show()
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false, isNSFW:isNSFW) { errorA in
                                StageManager.shared.sharePublic  (isNSFW: isNSFW) { errorB in
                                    dim.hide()
                                    toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                    isShowToast = errorA != nil || errorB != nil
                                    updateId()
                                    if errorA == nil && errorB == nil {
//                                        presentationMode.wrappedValue.dismiss()
                                        alertText = Text("save view publish sucess")
                                        isShowAlert = true

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
                    BannerAdView(sizeType: .GADAdSizeLargeBanner)
                        .padding(.top,20).padding(.bottom,20)

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
                        BannerAdView(sizeType: .GADAdSizeLargeBanner)
                            .padding(.top,20).padding(.bottom,20)
                        makeButtonList()
                            .padding(.bottom,10)
                    }
                }
            }
        }
        .actionSheet(isPresented: $isShowActionSheet) {
            ActionSheet(title: Text("share"), message: Text("share image desc"), buttons: actionSheetButtonsForShareItems)            
        }
        .navigationTitle(Text("save"))
        .onAppear {
            updateId()
            if let stage = StageManager.shared.stage {
                self.colors = stage.layers.map({ model in
                    return model.colors
                })
                backgroundColor = stage.backgroundColor
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
                isNSFW = stage.isNSFW
            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
        .alert(isPresented: $isShowAlert) {
            Alert(title: Text("alert"), message: alertText, dismissButton: nil)
        }
    }
}

struct SaveView_Previews: PreviewProvider {
    static var previews: some View {
        SaveView()
    }
}
