//
//  LayerEditView.swift
//  PixelArtMaker (macOS)
//
//  Created by Changyul Seo on 2022/02/22.
//

import SwiftUI

struct LayerEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var layers:[LayerModel] {
        return StageManager.shared.stage?.layers ?? []
    }
    
    @State var isOn:[Bool] = [] {
        didSet {
            print("isOn : \(isOn)")
            for (idx,value) in isOn.enumerated() {
                if let ol = StageManager.shared.stage?.layers[idx] {
                    StageManager.shared.stage?.layers[idx] = .init(colors: ol.colors, isOn: value, opacity: ol.opacity, id: "layer\(idx)")
                }
            }
        }
    }
    
    var body: some View {
        List {
            Canvas { context,size in
                for (idx,layer) in layers.enumerated() {
                    if isOn[idx] == false {
                        continue
                    }
                    for (y, list) in layer.colors.enumerated() {
                        for (x,color) in list.enumerated() {
                            context.fill(.init(roundedRect: .init(x: CGFloat(x),
                                                                  y: CGFloat(y),
                                                                  width: 1,
                                                                  height: 1),
                                               cornerSize: .zero), with: .color(color))
                        }
                    }
                }
            }.frame(width: layers.first?.width ?? 32, height: layers.first?.height ?? 32, alignment: .leading)
                .border(.white, width: 1.0).background(.clear)
                .background(StageManager.shared.stage?.backgroundColor ?? .clear)
            
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
                        
                        if isOn.count > 0 {
                            Toggle(isOn: $isOn[id]) {
                                
                            }.onChange(of: isOn[id]) { value in
                                for (idx,value) in isOn.enumerated() {
                                    if let ol = StageManager.shared.stage?.layers[idx] {
                                        StageManager.shared.stage?.layers[idx] = .init(colors: ol.colors, isOn: value, opacity: ol.opacity, id: "layer\(idx)")
                                    }
                                }
                                isOn = StageManager.shared.stage!.layers.map({ model in
                                    return model.isOn
                                })
                                print(isOn)
                            }
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
        .navigationTitle(.layer_edit_title)
        .toolbar {
            #if MAC
            #else
            EditButton()
            #endif
        }
        .onAppear {
            reload()
        }
    }
        
    fileprivate func reload() {
        isOn = StageManager.shared.stage?.layers.map({ model in
            return model.isOn
        }) ?? []
        print(isOn)
                    
    }
}

struct LayerEditView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditView()
    }
}
