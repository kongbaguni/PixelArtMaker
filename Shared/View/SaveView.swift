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
    
    @State var isLoading = false
    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    @State var title:String = ""
    @State var previewImage:Image? = nil
    
    var body: some View {
        VStack {            
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
                if StageManager.shared.stage?.documentId != nil {
                    Button {
                        isLoading = true
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false, complete: {isSucessA in
                                if sharedId != nil {
                                    StageManager.shared.sharePublic { isSucessB in
                                        isLoading = false
                                        if isSucessA && isSucessB {
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
                
                Button {
                    isLoading = true
                    googleAd.showAd { isSucess in
                        StageManager.shared.save(asNewForce: true, complete: { isSucess in
                            isLoading = false
                            if isSucess {
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                    }
                    
                } label: {
                    OrangeTextView(.save_as_new_file)
                }
                
            }
            if StageManager.shared.stage?.documentId != nil && sharedId == nil && AuthManager.shared.auth.currentUser?.isAnonymous == false {
                HStack {
                    Button {
                        isLoading = true
                        googleAd.showAd { isSucess in
                            StageManager.shared.save(asNewForce: false) { isSucessA in
                                StageManager.shared.sharePublic { isSucessB in
                                    isLoading = false
                                    if isSucessA && isSucessB {
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
            }
        }
        .onDisappear {
            StageManager.shared.stage?.title = title
        }
    }
}

struct SaveView_Previews: PreviewProvider {
    static var previews: some View {
        SaveView()
    }
}
