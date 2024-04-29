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
    
    @State var isLock:Bool = false
    
    func makeColorView(selectMode:ColorSelectMode, action:@escaping()->Void) -> some View   {
        Button {
            if isShowMenu {
                return
            }
            action()
        } label: {
            ZStack {
                if (selectMode == .background ? backgroundColor : forgroundColor).ciColor.alpha < 1 {
                    if let img = Image(pixelSize: (4, 4), backgroundColor: .clear, size: .init(width: 400, height: 200)) {
                        img.resizable()
                    }
                }
                if let img = UIImage(color: selectMode == .background ? backgroundColor : forgroundColor,
                                     size: .init(width: 30, height: 30)) {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        
                }
            }.frame(width: 30, height: 30, alignment: .center)
        }.border(Color.white, width: colorSelectMode == selectMode ? 2 : 0)
    }
    
    func makeFgBgSelectView() -> some View {
        ZStack {
            HStack {
                VStack {
                    makeColorView(selectMode: .foreground) {
                        colorSelectMode = .foreground
                    }
                    Spacer()
                }
                Spacer()
            }.zIndex(colorSelectMode == .foreground ? 1 : 0)
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    makeColorView(selectMode: .background) {
                        colorSelectMode = .background
                    }
                }
            }.zIndex(colorSelectMode == .background ? 1 : 0)
        }.frame(width: 50, height: 40, alignment: .center)
    }
    
    func makeColorPicker() -> some View {
        Group {
            switch colorSelectMode {
            case .foreground:
                ColorPicker(selection: $forgroundColor) {
                    
                }
                .onChange(of: forgroundColor) { newValue in
                    StageManager.shared.stage?.forgroundColor = newValue
                    print("change forground : \(newValue.string)")
                }
                .frame(width: 50, height: 30, alignment: .center)
            case .background:
                ColorPicker(selection: $backgroundColor) {
                    
                }
                .onChange(of: backgroundColor) { newValue in
                    print("change backgroundColor : \(newValue.string)")
                    if StageManager.shared.stage?.changeBgColor(color: newValue) == true {
                        undoCount = HistoryManager.shared.undoCount
                        redoCount = HistoryManager.shared.redoCount
                    }
                }
                .frame(width: 50, height: 30, alignment: .center)
            }
        }
    }
    
    func makeLockButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                isLock.toggle()
                UserDefaults.standard.colorPaletteIsLock = isLock
            }
        } label : {
            Image(systemName: isLock ? "lock" : "lock.open")
                .imageScale(.large)
                .foregroundColor(.gray)
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                makeFgBgSelectView()
                if isLock == false {
                    makeColorPicker()
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
                            .foregroundColor(.gray)
                    }
                }
                
                makeLockButton()
            }.padding(5)
        }
        .onAppear {
            isLock = UserDefaults.standard.colorPaletteIsLock
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
