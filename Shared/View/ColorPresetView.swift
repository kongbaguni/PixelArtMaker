//
//  ColorPresetView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/18.
//

import SwiftUI

fileprivate func getW(idx:Int)->CGFloat {
    return (UIScreen.main.bounds.width - 120) / CGFloat(Color.presetColors[idx].count)
}


struct ColorPresetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            ForEach(0..<Color.presetColors.count, id:\.self) { idx in
                Button {
                    print("idx : \(idx)")
                    StageManager.shared.stage?.parentColors = Color.presetColors[idx]
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        ForEach(0..<Color.presetColors[idx].count, id:\.self) { idx2 in
                            Text(" ")
                                .frame(width: getW(idx: idx),
                                       height: 50,
                                       alignment: .center)
                                .background(Color.presetColors[idx][idx2])
                            
                        }
                    }
                    
                }

            }
        }
    }
}

struct ColorPresetView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPresetView()
    }
}
