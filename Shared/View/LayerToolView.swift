//
//  LayerToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct LayerToolView: View {
    
    @Binding var isShowSelectLayerOnly:Bool
    @State var selectedLayerIndex = 0
    @Binding var toastMessage:String
    @Binding var isShowToast:Bool
    let previewImage:Image?
    let googleAd:GoogleAd
    @State var layerCount = 0
    @State var isLoading = false
    @Binding var isShowInAppPurches:Bool
    var body: some View {
        HStack {
            Spacer(minLength: 10)

            //MARK: - 미리보기
            if let img = previewImage {
                img.resizable().frame(width: 64, height: 64, alignment: .center)
            }

            //MARK: - 레이어 선택
            if let stage = StageManager.shared.stage {
                ForEach( 0 ..< layerCount, id:\.self) { idx in
                    if idx >= stage.layers.count {
                        EmptyView()
                    } else {
                        let layer = stage.layers[idx]
                        if let img = Image(totalColors: [layer.colors], blendModes: [.normal], backgroundColor: .white, size: stage.canvasSize) {
                            Button {
                                StageManager.shared.stage?.selectLayer(index: idx)
                                selectedLayerIndex = idx
                            } label : {
                                img.resizable().frame(width: 30, height: 30, alignment: .center)
                            }
                            .opacity(selectedLayerIndex == idx ? 1.0 : 0.2)
                        }
                    }
                }
                
                if layerCount < 5 {
                    Button {
                        if layerCount < InAppPurchaseModel.layerLimit {
                            if isLoading {
                                return
                            }
                            isLoading = true
                            googleAd.showAd { isSucess in
                                StageManager.shared.stage?.addLayer()
                                StageManager.shared.saveTemp { error in
                                    isLoading = false
                                    toastMessage = error?.localizedDescription ?? ""
                                    isShowToast = error != nil
                                    layerCount = StageManager.shared.stage?.layers.count ?? 0
                                }
                            }
                        }
                        else if InAppPurchaseModel.isSubscribe == false {
                            isShowInAppPurches = true
                        }
                    } label: {
                        Image(systemName: "plus.circle").imageScale(.large)
                            .opacity(isLoading ? 0.2 : 1.0)
                    }
                    .tint(.blue)
                }

            }
            
            //MARK: - 레이어 토글
            Button {
                isShowSelectLayerOnly.toggle()
            } label: {
                Image(systemName: "eye").imageScale(.large)
                    .opacity(isShowSelectLayerOnly ? 1.0 : 0.2)
            }

            //MARK:  레이어 편집
            NavigationLink(destination: {
                LayerEditView(googleAd: googleAd)
            }, label: {
                Image(systemName: "gear").imageScale(.large)
            })
            Spacer(minLength: 10)
            
        }.onAppear {
            selectedLayerIndex = StageManager.shared.stage?.selectedLayerIndex ?? 0
            layerCount = StageManager.shared.stage?.layers.count ?? 0
            print("layerCount : \(layerCount)")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                layerCount = StageManager.shared.stage?.layers.count ?? 0
            }
            NotificationCenter.default.addObserver(forName: .layerDataRefresh, object: nil, queue: nil) { _ in
                layerCount = StageManager.shared.stage?.layers.count ?? 0
            }
        }

    }
}

