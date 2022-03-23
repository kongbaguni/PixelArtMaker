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
            
    @State var blandModes:[Int] = []
    @State var isRequestMakePreview = false
    let blandModeStrs:[String] = [
        "normal",
        "multiply",
        "screen",
        "overlay",
        "darken",
        "lighten",
        "colorDodge",
        "colorBurn",
        "softLight",
        "hardLight",
        "difference",
        "exclusion",
        "hue",
        "saturation",
        "color",
        "luminosity",
        "clear",
        "copy",
        "sourceIn",
        "sourceOut",
        "sourceOut",
        "destinationOver",
        "destinationIn",
        "destinationOut",
        "destinationAtop",
        "xor",
        "plusDarker",
        "plusLighter"
    ]
    
    @State var previewImage:Image? = nil
    
    var body: some View {
        VStack {
            if let img = previewImage {
                img.resizable().frame(width: 200, height: 200, alignment: .center)
                    .opacity(isRequestMakePreview ? 0.1 : 1.0)
            }
            List {
                ForEach(layers.reversed(), id:\.self) { layer in
                    if let id = layers.firstIndex(of: layer) {
                        HStack {
                            Text("\(id)")
                                .foregroundColor(
                                    StageManager.shared.stage?.selectedLayerIndex == id ? .red : .white
                                )
                            Spacer()
                            if blandModes.count > id {
                                Picker(selection: $blandModes[id], label: Text("")) {
                                    ForEach(0..<blandModeStrs.count, id:\.self) { i in
                                        Text(blandModeStrs[i]).tag(i)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 100, height: 20, alignment: .center)
                                .onChange(of: blandModes[id]) { value in
                                    print(value)
                                    isRequestMakePreview = true
                                    if let new = CGBlendMode(rawValue: Int32(value)) { 
                                        StageManager.shared.stage?.change(blandMode: new , layerIndex: id)
                                        StageManager.shared.stage?.getImage(size: .init(width: 200, height: 200), complete: { image in
                                            previewImage = image
                                            isRequestMakePreview = false
                                        })
                                    }
                                }
                            }
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
        blandModes = StageManager.shared.stage?.layers.map({ model in
            return Int(model.blandMode.rawValue)
        }) ?? []
        StageManager.shared.stage?.getImage(size: .init(width: 200, height: 200), complete: { image in
            previewImage = image
        })
    }
}

struct LayerEditView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditView()
    }
}
