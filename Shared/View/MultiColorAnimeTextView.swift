//
//  SwiftUIView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2023/01/20.
//

import SwiftUI
fileprivate func makeColors(from:Color,to:Color,size:Int)->[Color] {
    var result:[Color] = []
    func makeArr(from:CGFloat,to:CGFloat)->[CGFloat] {
        var list:[CGFloat] = [from]
        let x = ((to - from) / CGFloat(size))
        for i in 1..<size-1 {
            list.append(from + x * CGFloat(i))
        }
        list.append(to)
        return list
    }
    let reds = makeArr(from: from.ciColor.red, to: to.ciColor.red)
    let greens = makeArr(from: from.ciColor.green, to: to.ciColor.green)
    let blues = makeArr(from: from.ciColor.blue, to: to.ciColor.blue)
    let alphas = makeArr(from: from.ciColor.alpha, to: to.ciColor.alpha)
    
    for (i,red) in reds.enumerated() {
        result.append(.init(.init(ciColor: .init(red: red, green: greens[i], blue: blues[i], alpha: alphas[i]))))
    }
    return result
}

struct MultiColorAnimeTextView: View {
    let texts:[Text]
    let fonts:[Font]
    let forgroundColors:[Color]
    let backgroundColors:[Color]
    let borderColors:[Color]
    let fps:Int
    init(texts:[Text],fonts:[Font],forgroundColors:[Color],backgroundColors:[Color], borderColors:[Color]? = nil,fps:Int) {
        self.fps = fps
        self.texts = texts
        self.fonts = fonts
        var fcs:[Color] = [forgroundColors.first!]
        if forgroundColors.count > 1 {
            for i in 0..<(forgroundColors.count - 1) {
                for color in  makeColors(from: forgroundColors[i], to: forgroundColors[i+1], size: fps) {
                    fcs.append(color)
                }
            }
        }
        self.forgroundColors = fcs
        var bcs:[Color] = [backgroundColors.first!]
        if backgroundColors.count > 1 {
            for i in 0..<(backgroundColors.count - 1) {
                for color in  makeColors(from: backgroundColors[i], to: backgroundColors[i+1], size: fps) {
                    bcs.append(color)
                }
            }
        }
        self.backgroundColors = bcs

        var bdcs:[Color] = fcs
        if let colors = borderColors {
            if colors.count > 1 {
                bdcs = [colors.first!]
                for i in 0..<(colors.count-1) {
                    for color in makeColors(from: colors[i], to: colors[i+1] , size: fps) {
                        bdcs.append(color)
                    }
                }
            }
        }
        self.borderColors = bdcs
    }
    
    @State var idx = 0
    @State var isAnimating: Bool = false

    private var textId:Int {
        idx % texts.count
    }
    
    private var fgColorId:Int {
        idx % forgroundColors.count
    }
    
    private var bgColorId:Int {
        idx % backgroundColors.count
    }
    
    private var borderColorId:Int {
        idx % borderColors.count
    }
    
    private var fontId:Int {
        idx % fonts.count
    }
    
    var body: some View {
        ZStack {
            texts[textId]
                .font(fonts[fontId])
                .padding(5)
                .foregroundColor(forgroundColors[fgColorId])
                .background(backgroundColors[bgColorId])
                .cornerRadius(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(borderColors[borderColorId], lineWidth: 4)
                }

        }.onAppear {
            changeIdx()
            isAnimating = true
        }

    }
    
    private func changeIdx() {
        idx += 1
        if idx > (texts.count *  fonts.count * forgroundColors.count * backgroundColors.count * 2)  {
            idx = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000 / fps)) {
            changeIdx()
        }
    }
}

