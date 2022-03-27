//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import RealmSwift

struct SaveView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var isLoading = false
    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    @State var title:String = "" 
    @State var previewImage:Image? = nil
    
    var body: some View {
        VStack {
            
            ScrollView {
                if let id = StageManager.shared.stage?.documentId {
                    TagView(Text(id))
                    
                    if let model = try! Realm().object(ofType: StagePreviewModel.self, forPrimaryKey: id) {
                        if model.shareDocumentId.isEmpty == false {
                            TagView(Text(model.shareDocumentId))
                        }
                    }
                }
                else {
                    OrangeTextView(Text("new file"))
                }
                
                ZStack {
                    if let img = previewImage {
                        img.resizable().frame(width: 200, height: 200, alignment: .center)
                            .opacity(isLoading ? 0.5 : 1.0)
                    }
                    ActivityIndicator(isAnimating: $isLoading, style: .large)
                        .frame(width: 200, height: 200, alignment: .center)
                }
                HStack {
                    if StageManager.shared.stage?.documentId != nil {
                        Button {
                            isLoading = true
                            GoogleAd.shared.showAd { isSucess in
                                StageManager.shared.save(asNewForce: false, complete: {
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
                        GoogleAd.shared.showAd { isSucess in
                            StageManager.shared.save(asNewForce: true, complete: {
                                isLoading = false
                                presentationMode.wrappedValue.dismiss()
                            })
                        }
                        
                    } label: {
                        OrangeTextView(.save_as_new_file)
                    }

                }
                if StageManager.shared.stage?.documentId != nil {
                    HStack {
                        Button {
                            isLoading = true
                            GoogleAd.shared.showAd { isSucess in
                                StageManager.shared.sharePublic { isSucess in
                                    isLoading = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
                        } label: {
                            OrangeTextView(Text("share public"))
                        }
                    }
                }

            }
        }
        .navigationTitle("save")
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
