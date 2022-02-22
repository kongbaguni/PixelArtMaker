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
        List {
            ForEach(layers, id:\.self) { layer in            
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
                            Text("Select Layer")
                        }

                    }

                }
            }
            Button {
                StageManager.shared.stage?.addLayer()
                reload()

            } label: {
                Text("make new layer")
            }

        }.onAppear {
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
