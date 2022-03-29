//
//  LayerEditView.swift
//  PixelArtMaker (macOS)
//
//  Created by Changyul Seo on 2022/02/22.
//

import SwiftUI

struct LayerEditView: View {
    let googleAd = GoogleAd()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var layers:[LayerModel] = []
            
    @State var blendModes:[Int] = []
    @State var isRequestMakePreview = false
    
    @State var isShowAlert = false
    @State var willDeleteLayerIdx:Int? = nil
    
    let blendModeStrs:[String] = [
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
                            Spacer()
                            if blendModes.count > id {
                                Picker(selection: $blendModes[id], label: Text("")) {
                                    ForEach(0..<blendModeStrs.count, id:\.self) { i in
                                        Text(blendModeStrs[i]).tag(i)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 100, height: 20, alignment: .center)
                                .onChange(of: blendModes[id]) { value in
                                    print(value)
                                    isRequestMakePreview = true
                                    if let new = CGBlendMode(rawValue: Int32(value)) { 
                                        StageManager.shared.stage?.change(blendMode: new , layerIndex: id)
                                        StageManager.shared.stage?.getImage(size: .init(width: 320, height: 320), complete: { image in
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
                        .swipeActions {
                            if layers.count > 1 {
                                Button {
                                    deleteLayer(idx: id)
                                } label: {
                                    Text("delete layer")
                                }
                                .tint(.red)
                            }
                        }
                        .padding(20)
                        .background(
                            StageManager.shared.stage?.selectedLayerIndex == id ? .yellow : .clear
                        )
                        .cornerRadius(20)
                    }
                }
                if layers.count < 5 {
                    Button {
                        googleAd.showAd { isSucess in
                            StageManager.shared.stage?.addLayer()
                            reload()
                            StageManager.shared.saveTemp {
                                
                            }
                        }
                    } label: {
                        Text.make_new_layer
                    }
                }
                
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(.layer_edit_title)
        .onAppear {
            reload()
        }
        
    }
    
    fileprivate func deleteLayer(idx:Int) {
        StageManager.shared.stage?.deleteLayer(idx: idx)
        reload()        
        StageManager.shared.saveTemp {
        
        }
    }
        
    fileprivate func reload() {
        layers = StageManager.shared.stage?.layers ?? []
        blendModes = StageManager.shared.stage?.layers.map({ model in
            return Int(model.blendMode.rawValue)
        }) ?? []
        StageManager.shared.stage?.getImage(size: .init(width: 320, height: 320), complete: { image in
            previewImage = image
        })
    }
}

struct LayerEditView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditView()
    }
}
