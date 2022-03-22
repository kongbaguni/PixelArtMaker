//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI

struct SaveView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    @State var title:String = "" 
    
    var body: some View {
        VStack {
            
            ScrollView {
                TextField("title", text: $title)
                    .frame(width: screenBounds.width - 20, height: 50, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                
                Canvas { context, size in
                    for data in colors {
                        let w = size.width / CGFloat(data.first?.count ?? 1)
                        for (y,list) in data.enumerated() {
                            for (x,color) in list.enumerated() {
                                if color != .clear {
                                    context.fill(.init(roundedRect: .init(x: CGFloat(x) * w - 0.01,
                                                                          y: CGFloat(y) * w - 0.01,
                                                                          width: w + 0.02,
                                                                          height: w + 0.02),
                                                       cornerSize: .zero), with: .color(color))
                                }
                            }
                        }
                    }
                }
                .background(backgroundColor)
                .frame(width: screenBounds.width - 20, height: screenBounds.width - 20, alignment: .center)
                .padding(20)
                
                
                Button {
                    StageManager.shared.saveTemp {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("save")
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
