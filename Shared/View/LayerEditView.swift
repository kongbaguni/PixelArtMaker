//
//  LayerEditView.swift
//  PixelArtMaker (macOS)
//
//  Created by Changyul Seo on 2022/02/22.
//

import SwiftUI

struct LayerEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isShowToast = false
    @State var toastMessage:String = ""

    @State var oldLayers:[LayerModel] = []
    @State var layers:[LayerModel] = []
    @State var selection:[Bool] = []
    
    @State var blendModes:[Int] = []
    @State var isRequestMakePreview = false
    
    @State var isShowAlert = false
    @State var willDeleteLayerIdx:Int? = nil
    @State var isLoading = false
    
    let googleAd:GoogleAd
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
                ForEach(layers, id:\.self) { layer in
                    if let id = layers.firstIndex(of: layer) {
                        HStack {
                            Text("\(layers.count - id)")
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
                                        StageManager.shared.stage?.change(blendMode: new , layerIndex: id, needAddHistory:false)
                                        StageManager.shared.stage?.getImage(size: Consts.previewImageSize, complete: { image in
                                            previewImage = image
                                            isRequestMakePreview = false
                                        })
                                    }
                                }
                            }
                            Button {
                                StageManager.shared.stage?.selectLayer(index:id)
                                presentationMode.wrappedValue.dismiss()
                                
                            } label: {
                                if let img = Image(totalColors: [layer.colors], blendModes: [.normal], backgroundColor: .clear, size: StageManager.shared.canvasSize) {
                                    img.resizable().frame(width: 40, height: 40, alignment: .center)
                                }
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
                            if layers.count < InAppPurchaseModel.layerLimit {
                                Button {
                                    if StageManager.shared.stage?.copyLayer(idx: id) == true {
                                        reload()
                                    }
                                } label: {
                                    Text("copy layer")
                                }
                                .tint(.blue)
                            }
                            
                        }
                        .padding(20)
                        .background(
                            selection[id] ? .yellow : .clear
                        )
                        .cornerRadius(20)
                    }
                }
                .onMove(perform: {source, destination in
                    layers.move(fromOffsets: source, toOffset: destination)
                    let oldselection = selection
                    selection.move(fromOffsets: source, toOffset: destination)
                    
                    if oldselection != selection {
                        if let idx = selection.firstIndex(of: true) {
                            StageManager.shared.stage?.selectLayer(index: idx)
                        }
                    }
                    StageManager.shared.stage?.layers = layers
                    StageManager.shared.stage?.reArrangeLayers()
                    reload()
                })
                if layers.count < InAppPurchaseModel.layerLimit {
                    Button {
                        if isLoading {
                            return
                        }
                        isLoading = true
                        googleAd.showAd { isSucess in
                            StageManager.shared.stage?.addLayer()
                            reload()
                            StageManager.shared.saveTemp { error in
                                toastMessage = error?.localizedDescription ?? ""
                                isShowToast = error != nil
                                isLoading = false 
                            }
                        }
                    } label: {
                        Text.make_new_layer
                    }
                }
                
            }
        }
        .toolbar(content: {
            EditButton()
        })
        
        .listStyle(GroupedListStyle())
        .navigationTitle(.layer_edit_title)
        .onAppear {
            reload()
            oldLayers = layers
        }
        .onDisappear {
            if let newLayer = StageManager.shared.stage?.layers {
                if oldLayers != newLayer {
                    HistoryManager.shared.addHistory(.init( layerTotalEdit: .init(before: .init(layers: oldLayers), after: .init(layers:newLayer))))
                }
            }
        }
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
        
        
    }
    
    
    fileprivate func deleteLayer(idx:Int) {
        StageManager.shared.stage?.deleteLayer(idx: idx)
        reload()
        StageManager.shared.saveTemp { error in
            toastMessage = error?.localizedDescription ?? ""
            isShowToast = error != nil
            NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
        }
    }
    
    fileprivate func reload() {
        layers = StageManager.shared.stage?.layers ?? []
        layerSelectionRefresh()
        blendModes = StageManager.shared.stage?.layers.map({ model in
            return Int(model.blendMode.rawValue)
        }) ?? []
        StageManager.shared.stage?.getImage(size: Consts.previewImageSize, complete: { image in
            previewImage = image
        })
    }
    
    fileprivate func layerSelectionRefresh() {
        selection = []
        for i in 0..<layers.count {
            selection.append(i == StageManager.shared.stage?.selectedLayerIndex)
        }
    }
}

