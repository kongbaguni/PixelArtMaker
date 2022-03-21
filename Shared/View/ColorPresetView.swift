//
//  ColorPresetView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/18.
//

import SwiftUI

fileprivate func getW(name:String,idx:Int)->CGFloat {
    if let list = Color.presetColors[name] {
        let count = list[idx].count
        return (UIScreen.main.bounds.width - 120) / CGFloat(count)
    }
    return 0.0
}

fileprivate var colorNames:[String] {
    let keys = Color.presetColors.map { result in
        return result.key
    }
    return keys.sorted()
}


struct ColorPresetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            ForEach(0..<Color.presetColors.count, id:\.self) { idx in
                let key = colorNames[idx]
                if let arr = Color.presetColors[key] {
                    Section(header:Text(key)) {
                        ForEach(0..<arr.count, id:\.self) { i in
                            Button {
                                StageManager.shared.stage?.parentColors = arr[i]
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                HStack {
                                    ForEach(0..<arr[i].count, id:\.self) { i2 in
                                        Text(" ")
                                            .frame(width: getW(name:key,idx:i),
                                                   height: 50,
                                                   alignment: .center)
                                            .background(arr[i][i2])
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                }

            }
        }.navigationTitle(Text.menu_color_select_title)
    }
}

struct ColorPresetView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPresetView()
    }
}
