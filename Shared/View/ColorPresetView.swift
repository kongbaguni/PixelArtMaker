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
        return (screenBounds.width - 120) / CGFloat(count)
    }
    return 0.0
}




struct ColorPresetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private var colorPresetNames:[String] {
        Color.colorPresetNames
    }
    
    @State var colorPresetNameIdx:Int = 0

    var body: some View {

        VStack {
            Picker(selection:$colorPresetNameIdx, label:Text("preset")) {
                ForEach(0..<colorPresetNames.count, id:\.self) { idx in
                    Text(colorPresetNames[idx])
                }
            }
        }
        ScrollViewReader { proxy in
            List {
                let key = colorPresetNames[colorPresetNameIdx]
                if let arr = Color.presetColors[key] {
                    ForEach(0..<arr.count, id:\.self) { i in
                        Button {
                            UserDefaults.standard.lastColorPresetRowSelectionIndex = i
                            StageManager.shared.stage?.paletteColors = arr[i]
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
            }.onAppear {
                colorPresetNameIdx = UserDefaults.standard.lastColorPresetSelectionIndex
                DispatchQueue.main.async {
                    proxy.scrollTo(UserDefaults.standard.lastColorPresetRowSelectionIndex, anchor: .top)
                }
            }.onDisappear {
                UserDefaults.standard.lastColorPresetSelectionIndex = colorPresetNameIdx
            }
        }
        
//        List {
//            ForEach(0..<Color.presetColors.count, id:\.self) { idx in
//                let key = colorPresetNames[idx]
//                if let arr = Color.presetColors[key] {
//                    Section(header:Text(key)) {
//                        ForEach(0..<arr.count, id:\.self) { i in
//                            Button {
//                                StageManager.shared.stage?.paletteColors = arr[i]
//                                presentationMode.wrappedValue.dismiss()
//                            } label: {
//                                HStack {
//                                    ForEach(0..<arr[i].count, id:\.self) { i2 in
//                                        Text(" ")
//                                            .frame(width: getW(name:key,idx:i),
//                                                   height: 50,
//                                                   alignment: .center)
//                                            .background(arr[i][i2])
//
//                                    }
//                                }
//                            }
//                        }
//
//                    }
//                }
//
//            }
//        }
//        .navigationTitle(Text.menu_color_select_title)
//        .onAppear {
//
//        }
    }
}

struct ColorPresetView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPresetView()
    }
}
