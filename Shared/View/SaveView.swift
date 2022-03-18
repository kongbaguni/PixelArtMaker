//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SaveView: View {
    let collection = Firestore.firestore().collection("pixelart")
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    @State var title:String = "" 
    
    var body: some View {
        ScrollView {
            TextField("title", text: $title)
                .frame(width: UIScreen.main.bounds.width - 20, height: 50, alignment: .center)
                .border(.white, width: 0.5)

            Canvas { context, size in
                for data in colors {
                    let w = size.width / CGFloat(data.first?.count ?? 1)
                    for (y,list) in data.enumerated() {
                        for (x,color) in list.enumerated() {
                            if color != .clear {
                                context.fill(.init(roundedRect: .init(x: CGFloat(x) * w ,
                                                                      y: CGFloat(y) * w ,
                                                                      width: w ,
                                                                      height: w ),
                                                   cornerSize: .zero), with: .color(color))
                            }
                        }
                    }
                }
            }
            .background(backgroundColor)
            .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20, alignment: .center)
            .padding(20)

            
            Button {
                if let stage = StageManager.shared.stage {
                    let str = stage.base64EncodedString

                    let email = AuthManager.shared.auth.currentUser?.email ?? "guest"
                    let data = [
                        "title":title,
                        "email":AuthManager.shared.auth.currentUser?.email ?? "guest",
                        "data":str
                    ]
                    
                    collection.document(email).setData(data, merge: true) { error in
                        print(error?.localizedDescription ?? "성공")
                        if error == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                }
            } label: {
                Text("save")
            }
        }
        .navigationTitle("save")
        .onAppear {
            if let stage = StageManager.shared.stage {
                self.colors = stage.layers.map({ model in
                    return model.colors
                })
                title = stage.title ?? ""
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
