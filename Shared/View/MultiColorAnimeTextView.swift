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
    @State var idx = 0
    @State var isAnimate = false 
    private var textId:Int {
        idx % texts.count
    }
    
    private var fgColorId:Int {
        idx % forgroundColors.count
    }
    
    private var bgColorId:Int {
        idx % backgroudColors.count
    }
    
    private var fontId:Int {
        idx % fonts.count
    }
    
    var body: some View {
        texts[textId]
            .font(fonts[fontId])
            .padding(5)
            .foregroundColor(forgroundColors[fgColorId])
            .background(backgroudColors[bgColorId])
            .onAppear {
                changeIdx()
            }
            .cornerRadius(5)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(forgroundColors[fgColorId], lineWidth: 4)
            }
            .animation(SwiftUI.Animation.easeIn(duration: Double(millisecond) / 1000), value: isAnimate)
    }
    
    private func changeIdx() {
        idx += 1
        isAnimate = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            changeIdx()
        }
    }
}

