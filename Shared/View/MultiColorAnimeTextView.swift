//
//  SwiftUIView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2023/01/20.
//

import SwiftUI

struct MultiColorAnimeTextView: View {
    let texts:[Text]
    let fonts:[Font]
    let forgroundColors:[Color]
    let backgroudColors:[Color]
    let millisecond:Int
    @State var idx:UInt8 = 0
    @State var isAnimating: Bool = false
    var newIdx:Int {
        Int(Double(idx) / 2)
    }
    private var textId:(Int,Int) {
        (newIdx % texts.count, (newIdx + 1) % texts.count)
    }
    
    private var fgColorId:(Int,Int) {
        (newIdx % forgroundColors.count,(newIdx + 1) % forgroundColors.count)
    }
    
    private var bgColorId:(Int,Int) {
        (newIdx % backgroudColors.count,(newIdx + 1) % backgroudColors.count)
    }
    
    private var fontId:(Int,Int) {
        (newIdx % fonts.count,(newIdx + 1) % fonts.count)
    }
    
    var body: some View {
        ZStack {
            texts[textId.0]
                .font(fonts[fontId.0])
                .padding(5)
                .foregroundColor(forgroundColors[fgColorId.0])
                .background(backgroudColors[bgColorId.0])
                .cornerRadius(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(forgroundColors[fgColorId.0], lineWidth: 4)
                }
            
            texts[textId.1]
                .font(fonts[fontId.1])
                .padding(5)
                .foregroundColor(forgroundColors[fgColorId.1])
                .background(backgroudColors[bgColorId.1])
                .cornerRadius(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(forgroundColors[fgColorId.1], lineWidth: 4)
                }
                .opacity((idx % 2 == 0) ? 0.0 : 1.0 )
                .animation(.easeOut, value: isAnimating)

        }.onAppear {
            changeIdx()
            isAnimating = true
        }

    }
    
    private func changeIdx() {
        idx += 1
        if idx > (texts.count *  fonts.count * forgroundColors.count * backgroudColors.count * 2)  {
            idx = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            changeIdx()
        }
    }
}

