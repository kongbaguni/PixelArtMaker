//
//  LayerEditView.swift
//  PixelArtMaker (macOS)
//
//  Created by Changyul Seo on 2022/02/22.
//

import SwiftUI

struct LayerEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var layers:[LayerModel] = []
            
        
    var body: some View {
        VStack {
            Canvas { context,size in
                for layer in layers {
                    for (y, list) in layer.colors.enumerated() {
                        for (x,color) in list.enumerated() {
                            context.fill(.init(roundedRect: .init(x: CGFloat(x)*4,
                                                                  y: CGFloat(y)*4,
                                                                  width: 4,
                                                                  height: 4),
                                               cornerSize: .zero), with: .color(color))
                        }
                    }
                }
            }.frame(width: (layers.first?.width ?? 32) * 4, height: (layers.first?.height ?? 32) * 4, alignment: .leading)
                .border(.white, width: 1.0).background(.clear)
                .background(StageManager.shared.stage?.backgroundColor ?? .clear)
                .padding(20)
            
            List {
                ForEach(layers.reversed(), id:\.self) { layer in
                    if let id = layers.firstIndex(of: layer) {
                        HStack {
                            Text("\(id)")
                                .foregroundColor(
                                    StageManager.shared.stage?.selectedLayerIndex == id ? .red : .white
                                )
                            
                            Canvas { context,size in
                                for (y, list) in layer.colors.enumerated() {
                                    for (x,color) in list.enumerated() {
                                        context.fill(.init(roundedRect: .init(x: CGFloat(x),
                                                                              y: CGFloat(y),
                                                                              width: 1,
                                                                              height: 1),
                                                           cornerSize: .zero), with: .color(color))
                                    }
                                }
                            }.frame(width: CGFloat(layer.colors.first!.count),
                                    height: CGFloat(layer.colors.count), alignment: .center)
                            Button {
                                StageManager.shared.stage?.selectLayer(index: id)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text(" ")
                            }
                        }
                    }
                }
                
                Button {
                    StageManager.shared.stage?.addLayer()
                    reload()
                    
                } label: {
                    Text.make_new_layer
                }
                
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(.layer_edit_title)
        .onAppear {
            reload()
        }
    }
        
    fileprivate func reload() {
        layers = StageManager.shared.stage?.layers ?? []
    }
}

struct LayerEditView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditView()
    }
}
