//
//  LayerToolView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct LayerToolView: View {
    @Binding var isShowSelectLayerOnly:Bool
    
    let previewImage:Image?
    
    var body: some View {
        HStack {
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
        }

    }
}

