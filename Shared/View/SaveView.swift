//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI

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
                    Text(id)
                        .padding(5)
                        .foregroundColor(.k_tagText)
                        .background(Color.k_tagBackground)
                        .cornerRadius(10)
                }
                else {
                    Text("new file")
                        .padding(5)
                        .foregroundColor(.k_tagText)
                        .background(Color.k_tagBackground)
                        .cornerRadius(10)
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
                                    StageManager.shared.loadList { result in
                                        isLoading = false
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                })
                            }
                            
                        } label: {
                            Text.save_to_existing_file
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color.orange)
                                .cornerRadius(10)
                            
                        }
                    }
                    
                    Button {
                        isLoading = true
                        GoogleAd.shared.showAd { isSucess in
                            StageManager.shared.save(asNewForce: true, complete: {
                                StageManager.shared.loadList { result in
                                    isLoading = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            })
                        }
                        
                    } label: {
                        Text.save_as_new_file
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Color.orange)
                            .cornerRadius(10)
                        
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
