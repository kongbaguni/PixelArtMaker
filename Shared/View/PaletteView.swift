//
//  PalleteView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/09.
//

import SwiftUI

struct PaletteView: View {
    enum ColorSelectMode {
        case foreground
        case background
    }
    
    @Binding var forgroundColor:Color
    @Binding var backgroundColor:Color
    @Binding var colorSelectMode:ColorSelectMode
    @Binding var undoCount:Int
    @Binding var redoCount:Int
    let isShowMenu:Bool
    let paletteColors:[Color]
    @Binding var isShowColorPresetView:Bool
    
    var body: some View {
        HStack {
            VStack {
                Button {
                    if isShowMenu {
                        return
                    }
                    colorSelectMode = .foreground
                } label: {
                    Text("").frame(width: 28, height: 15, alignment: .center)
                        .background(forgroundColor)
                }.border(Color.white, width: colorSelectMode == .foreground ? 2 : 0)
                
                Button {
                    if isShowMenu {
                        return
                    }
                    
                    colorSelectMode = .background
                } label: {
                    Text("").frame(width: 28, height: 15, alignment: .center)
                        .background(backgroundColor)
                }.border(Color.white, width: colorSelectMode == .background ? 2 : 0)
            }
            switch colorSelectMode {
            case .foreground:
                ColorPicker(selection: $forgroundColor) {
                    
                }
                .onChange(of: forgroundColor) { newValue in
                    print("change forground : \(newValue.string)")
                }
                .frame(width: 40, height: 40, alignment: .center)
            case .background:
                ColorPicker(selection: $backgroundColor) {
                    
                }
                .onChange(of: backgroundColor) { newValue in
                    print("change backgroundColor : \(newValue.string)")
                    if StageManager.shared.stage?.changeBgColor(color: newValue) == true {
                        undoCount = StageManager.shared.stage?.history.count ?? 0
                        redoCount = 0
                    }
                }
                .frame(width: 40, height: 40, alignment: .center)
            }
            
            Spacer()
            switch colorSelectMode {
            case .foreground:
                 SimplePaleteView(color: $forgroundColor, paletteColors: paletteColors)
            case .background:
                SimplePaleteView(color: $backgroundColor, paletteColors: paletteColors)
            }
            
            Button {
                isShowColorPresetView = true
            } label : {
                Image(systemName: "ellipsis")
                    .imageScale(.large)
            }
        }
    }
}


struct SimplePaleteView : View {
    @Binding var color:Color
    let paletteColors:[Color]
    
    var body: some View {
        HStack {
            ForEach(0..<7) { i in
                Button {
                    color = paletteColors[i]
                    
                } label: {
                    Spacer().frame(width: 26, height: 32, alignment: .center)
                        .background(paletteColors[i])
                }
                .border(.white, width: color == paletteColors[i] ? 5.0 : 0.5)
                .padding(SwiftUI.EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 1))
            }
        }
    }
}
