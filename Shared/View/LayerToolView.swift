//
//  LayerToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct LayerToolView: View {
    @Binding var isShowSelectLayerOnly:Bool
    @State var selectedLayerIndex:Int = 0
    let previewImage:Image?
    
    var body: some View {
        HStack {
            Spacer(minLength: 10)
            if let stage = StageManager.shared.stage {
                ForEach( 0 ..< stage.layers.count, id:\.self) { idx in
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
            
            //MARK: - 레이어 토글
            Button {
                isShowSelectLayerOnly.toggle()
            } label: {
                Image(systemName: "eye").imageScale(.large)
                    .opacity(isShowSelectLayerOnly ? 1.0 : 0.2)
            }

            //MARK:  미리보기
            NavigationLink(destination: {
                LayerEditView()
            }, label: {
                if let img = previewImage {
                    img.resizable().frame(width: 64, height: 64, alignment: .center)
                }
            })
            Spacer(minLength: 10)
        }.onAppear {
            selectedLayerIndex = StageManager.shared.stage?.selectedLayerIndex ?? 0
        }

    }
}

