//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import RealmSwift
fileprivate var sharedId:String? {
    if let id = StageManager.shared.stage?.documentId {
        if let model = try! Realm().object(ofType: MyStageModel.self, forPrimaryKey: id) {
            return model.shareDocumentId.isEmpty ? nil : model.shareDocumentId
        }
    }
    return nil
}

struct SaveView: View {
    let googleAd = GoogleAd()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var isLoading = false
    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    @State var title:String = ""
    @State var previewImage:Image? = nil
    @State var shareImageData:Data? = nil
    
    var body: some View {
        ScrollView {
            ProfileView()
            ZStack {
                if let img = previewImage {
                    img.resizable().frame(width: screenBounds.width - 10, height: screenBounds.width - 10 , alignment: .center)
                        .opacity(isLoading ? 0.5 : 1.0)
                }
                ActivityIndicator(isAnimating: $isLoading, style: .large)
                    .frame(width: 200, height: 200, alignment: .center)
            }
            
            if let id = StageManager.shared.stage?.documentId {
                HStack {
                    Text("currentId")
                    TagView(Text(id))
                }
                
                if let id = sharedId {
                    HStack {
                        Text("sharedId")
                        TagView(Text(id))
                    }
                }
            }
            HStack {
                //MARK : 기존 파일에 저장
                if StageManager.shared.stage?.documentId != nil && StageManager.shared.stage?.isMyPicture == true {
                    Button {
                        isLoading = true
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false, complete: {errorA in
                                if sharedId != nil {
                                    StageManager.shared.sharePublic { errorB in
                                        isLoading = false
                                        isShowToast = errorA != nil || errorB != nil
                                        toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                        if errorA == nil && errorB == nil  {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    return
                                }
                                isLoading = false
                                presentationMode.wrappedValue.dismiss()
                            })
                        }
                        
                    } label: {
                        OrangeTextView(.save_to_existing_file)
                        
                    }
                }
                //MARK: 새 파일로 저장
                Button {
                    isLoading = true
                    googleAd.showAd { isSucess in
                        StageManager.shared.save(asNewForce: true, complete: { error in
                            
                            isLoading = false
                            toastMessage = error?.localizedDescription ?? ""
                            isShowToast = error != nil
                            if error == nil  {
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                    }
                    
                } label: {
                    OrangeTextView(.save_as_new_file)
                }
                
            }
            
            if let img = shareImageData {
                Button {
                    share(items: [img])
                } label: {
                    OrangeTextView(Text("share"))
                }
            }
            
            if StageManager.shared.stage?.documentId != nil && sharedId == nil && AuthManager.shared.auth.currentUser?.isAnonymous == false {
                HStack {
                    Button {
                        isLoading = true
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false) { errorA in
                                StageManager.shared.sharePublic { errorB in
                                    isLoading = false
                                    toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                    isShowToast = errorA != nil || errorB != nil
                                    
                                    if errorA == nil && errorB == nil {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }                            
                        }
                        
                    } label: {
                        OrangeTextView(Text("share public"))
                    }
                }
            }
            
        }
        .navigationTitle(Text("save"))
        .onAppear {
            if let stage = StageManager.shared.stage {
                self.colors = stage.layers.map({ model in
                    return model.colors
                })
                backgroundColor = stage.backgroundColor
                title = stage.title ?? ""
                stage.getImage(size: .init(width: 320, height: 320)) { image in
                    previewImage = image
                }
                let data = stage.makeImageDataValue(size: .init(width: 320, height: 320))
                shareImageData = data
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
