//
//  CanvasView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/10.
//

import SwiftUI

struct CanvasView: View {
    @Binding var pointer:CGPoint
    @Binding var isShowMenu:Bool
    @Binding var isLoadingAnimated:Bool
    @Binding var isLongPressing:Bool
    @Binding var timer: Timer?
    
    let colors:[[Color]]
    let isLoadingDataFin:Bool
    let isShowSelectLayerOnly:Bool
    let screenWidth:CGFloat
    let backgroundColor:Color
    let layers:[LayerModel]
    let zoomFrame:(width:Int,height:Int)
    let zoomOffset:(x:Int,y:Int)
    
    private var pw:CGFloat {
        return screenWidth / CGFloat(zoomFrame.width)
    }
    private var ph:CGFloat {
        return screenWidth / CGFloat(zoomFrame.height)
    }

    private func getIndex(location:CGPoint)->(Int,Int) {
        let x = Int(location.x / pw) + zoomOffset.x
        let y = Int(location.y / ph) + zoomOffset.y
        return (x,y)
    }

    var body: some View {
        ZStack(alignment: .center) {
            Canvas { context, size in
                func draw() {
                    let w = size.width / CGFloat(zoomFrame.width)
                    for (i,layer) in (StageManager.shared.stage?.layers ?? []).reversed().enumerated() {
                        context.blendMode = .init(rawValue: layer.blendMode.rawValue)
                        for y in zoomOffset.y..<zoomOffset.y+zoomFrame.height {
                            if y < 0 || y >= layer.colors.count {
                                continue
                            }
                            let list = layer.colors[y]
                            
                            for x in zoomOffset.x..<zoomOffset.x+zoomFrame.width {
                                if x < 0 || x >= list.count {
                                    continue
                                }
                                let color = list[x]
                                if (i == 0) {
                                    var cornerSize:CGSize {
                                        if w > 8 {
                                            return .init(width: 4, height: 4)
                                        }
                                        if w > 3 {
                                            return .init(width: 1, height: 1)
                                        }
                                        return .zero
                                    }
                                    context.fill(.init(roundedRect: .init(x: CGFloat(x - zoomOffset.x) * w + 1,
                                                                          y: CGFloat(y - zoomOffset.y) * w + 1,
                                                                          width: w - 2.0,
                                                                          height: w - 2.0),
                                                       cornerSize: cornerSize),
                                                 with: .color(backgroundColor))
                                }
                                
                                if color != .clear {
                                    
                                    context.fill(.init(roundedRect: .init(x: CGFloat(x - zoomOffset.x) * w + 0.5,
                                                                          y: CGFloat(y - zoomOffset.y) * w + 0.5,
                                                                          width: w - 1.0,
                                                                          height: w - 1.0),
                                                       cornerSize: .zero), with: .color(
                                                        isShowSelectLayerOnly
                                                        ? (layers.count - i - 1 == StageManager.shared.stage?.selectedLayerIndex ? color : .clear)
                                                        : color
                                                       ))
                                }
                                
                            }
                        }
                        
                    }
                    for rect in [
                        CGRect(x: 0, y: 0, width: size.width, height: size.height),
                        CGRect(x: size.width*0.25, y: 0, width: 0, height: size.height),
                        CGRect(x: size.width*0.5, y: 0, width: 0, height: size.height),
                        CGRect(x: size.width*0.75 , y: 0, width: 0, height: size.height),
                        CGRect(x: 0, y: size.height * 0.25 , width: size.width, height: 0),
                        CGRect(x: 0, y: size.height * 0.5 , width: size.width, height: 0),
                        CGRect(x: 0, y: size.height * 0.75 , width: size.width, height: 0)
                    ]{
                        context.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(.green.opacity(0.5)))
                    }
                    if isShowMenu == false {
                        context.blendMode = .difference
                        context.stroke(Path(roundedRect: .init(
                            x: (pointer.x - CGFloat(zoomOffset.x)) * w,
                            y: (pointer.y - CGFloat(zoomOffset.y)) * w,
                            width: pw, height: pw), cornerRadius: 0), with: .color(.k_pointer))
                        context.stroke(Path(roundedRect: .init(
                            x: (pointer.x - CGFloat(zoomOffset.x)) * w + 1,
                            y: (pointer.y - CGFloat(zoomOffset.y)) * w + 1,
                            width: pw - 2, height: pw - 2), cornerRadius: 0), with: .color(.k_pointer2))
                    }
                }
                if AuthManager.shared.isSignined {
                    if isLoadingDataFin {
                        draw()
                    }
                    else {
                        for i in 1...30 {
                            let a = CGFloat(i * 10)
                            let b = a * 2
                            let r = CGFloat(35 - i)
                            context.stroke(Path(roundedRect: .init(x: a, y: a,
                                                                   width: size.width - b,
                                                                   height: size.height - b),
                                                cornerSize: .init(width: r, height: r)),
                                           with: .color(.randomColor))
                        }
                    }
                } else {
                    draw()
                }
            }
            .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                print(value.location)
                if isShowMenu {
                    withAnimation(.easeInOut) {
                        isShowMenu = false
                    }
                    return
                }
                let idx = getIndex(location: value.location)
                pointer = .init(x: idx.0, y: idx.1)
                if isLongPressing {
                    isLongPressing = false
                    timer?.invalidate()
                }
            }))
            if isLoadingDataFin == false {
                ActivityIndicator(isAnimating: $isLoadingAnimated, style: .large)
                
            }
        }
        .frame(width: screenWidth, height: screenWidth, alignment: .center)
        .padding(0)

    }
}


