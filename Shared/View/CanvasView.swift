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
    let forgroundColor:Color
    let backgroundColor:Color
    let layers:[LayerModel]
    let zoomFrame:(width:Int,height:Int)
    let zoomOffset:(x:Int,y:Int)
    let drawBegainPointer:CGPoint?
    let tracingImage:PixelDrawView.TracingImageData?
    @State var paintingPoint:Set<PathFinder.Point>? = nil

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

    private func getTracingFrame(imageSize:CGSize)->CGRect {
        let canvasSize = StageManager.shared.canvasSize
        let asize = imageSize / canvasSize

        return .init(x: CGFloat(zoomOffset.x) * asize.width ,
                     y: CGFloat(zoomOffset.y) * asize.height,
                     width: CGFloat(zoomFrame.width) * asize.width,
                     height: CGFloat(zoomFrame.height) * asize.height )
    }
    var body: some View {
        ZStack(alignment: .center) {
            Canvas { context, size in
                let w = size.width / CGFloat(zoomFrame.width)
                
                func drawTransperBg() {
                    let bsize = zoomFrame.width
                    let boxSize:CGSize = size / bsize
                    let transparencyColor = UserDefaults.standard.transparencyColor 

                    for x in 0...bsize {
                        for y in 0...bsize {
                            let rect = CGRect(origin: .init(x: CGFloat(x) * boxSize.width, y: CGFloat(y) * boxSize.height),
                                              size: boxSize)
                            
                            let isGray = ((y % 2) + x) % 2 == 0
                            context.fill(.init(roundedRect: rect, cornerSize: .zero),
                                         with: .color(isGray
                                                      ? Color(uiColor: transparencyColor.a)
                                                      : Color(uiColor: transparencyColor.b)
                                                     )
                            )
                            
                        }
                    }
                }
                
                func drawGridLine() {
                    let bsize = zoomFrame.width
                    let boxSize:CGSize = size / bsize
                    
                    for x in 0...bsize {
                        for y in 0...bsize {
                            let rect = CGRect(origin: .init(x: CGFloat(x) * boxSize.width, y: CGFloat(y) * boxSize.height),
                                              size: boxSize)
                            
                            context.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(Color(white: 0.8).opacity(0.1)))
                        }
                    }

                }
                
                func drawPointer() {
                    
                    if let p = drawBegainPointer {
                        for point in PathFinder.findLine(startCGPoint: p, endCGPoint: pointer) {
                            let cp = point.cgpoint
                            let path = Path(roundedRect: .init(
                                x: (cp.x - CGFloat(zoomOffset.x)) * w,
                                y: (cp.y - CGFloat(zoomOffset.y)) * w,
                                width: pw, height: pw),cornerRadius: 0)
                                            
                            context.blendMode = .normal
                            context.fill(path, with: .color(forgroundColor))
                            context.blendMode = .difference
                            context.stroke(path, with:.color(.k_pointer2), lineWidth:2)

                        }
                        context.blendMode = .difference
                        context.stroke(Path(roundedRect: .init(
                            x: (p.x - CGFloat(zoomOffset.x)) * w,
                            y: (p.y - CGFloat(zoomOffset.y)) * w,
                            width: pw, height: pw), cornerRadius: 0), with: .color(.k_pointer2), lineWidth: 4)
                        
                    }

                    context.blendMode = .difference
                    context.stroke(Path(roundedRect: .init(
                        x: (pointer.x - CGFloat(zoomOffset.x)) * w,
                        y: (pointer.y - CGFloat(zoomOffset.y)) * w,
                        width: pw, height: pw), cornerRadius: 0), with: .color(.k_pointer), lineWidth: 4)
                }
                
                func drawPainting() {
                    if let points = paintingPoint {
                        for point in points {
                            let cp = point.cgpoint
                            let path = Path(roundedRect: .init(
                                x: (cp.x - CGFloat(zoomOffset.x)) * w,
                                y: (cp.y - CGFloat(zoomOffset.y)) * w,
                                width: pw, height: pw),cornerRadius: 0)
                                            
                            context.blendMode = .normal
                            context.fill(path, with: .color(forgroundColor == .clear ? .blue : forgroundColor))
                        }
                    }
                }
                
                func drawImage() {
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
                                let rect:CGRect = .init(x: CGFloat(x - zoomOffset.x) * w ,
                                                        y: CGFloat(y - zoomOffset.y) * w ,
                                                        width: w,
                                                        height: w)
                                
                                let color = list[x]
                                
                                if color != .clear {
                                    if isShowSelectLayerOnly {
                                        let isCurrent = layers.count - i - 1 == StageManager.shared.stage?.selectedLayerIndex
                                        if isCurrent {                                            
                                            context.fill(.init(roundedRect: rect, cornerSize:.zero), with: .color(color))
                                        }
                                        
                                    }
                                    else  {
                                        context.fill(.init(roundedRect: rect, cornerSize:.zero), with: .color(color))
                                    }

                                }
                                
                            }
                        }
                        
                    }
                }
                
                func draw() {
                    if backgroundColor.ciColor.alpha < 1.0 || isShowSelectLayerOnly {
                        drawTransperBg()
                    }
                    if isShowSelectLayerOnly == false {
                        context.fill(.init(roundedRect: .init(origin:.zero, size:size),
                                           cornerSize: .zero),
                                     with: .color(backgroundColor))
                    }
                    drawImage()
                    drawGridLine()
                    drawPointer()
                    drawPainting()
                }
                if AuthManager.shared.isSignined {
                    if isLoadingDataFin {
                        draw()
                    }
                    else {
                        drawTransperBg()
//                        for i in 1...30 {
//                            let a = CGFloat(i * 10)
//                            let b = a * 2
//                            let r = CGFloat(35 - i)
//                            context.stroke(Path(roundedRect: .init(x: a, y: a,
//                                                                   width: size.width - b,
//                                                                   height: size.height - b),
//                                                cornerSize: .init(width: r, height: r)),
//                                           with: .color(.randomColor))
//                        }
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
                let newPoint = CGPoint(x: idx.0, y: idx.1)
                
                if StageManager.shared.canvasSize.isOut(cgPoint: newPoint) == false {
                    pointer = newPoint
                }
                if isLongPressing {
                    isLongPressing = false
                    timer?.invalidate()
                }
            }))
            if isShowSelectLayerOnly == false {
                if let data = tracingImage {
                    Image(uiImage: data.image.sd_croppedImage(with: getTracingFrame(imageSize: data.image.size))!)
                        .resizable()
                        .blendMode(.normal)
                        .opacity(data.opacity)
                        .frame(width: screenWidth,
                               height: screenWidth, alignment: .center)
                }
                    
            }

            if isLoadingDataFin == false {
                ActivityIndicator(isAnimating: $isLoadingAnimated, style: .large)
                
            }
        }
        .onAppear(perform: {
            NotificationCenter.default.addObserver(forName: .paintingProcess, object: nil, queue: nil) { noti in
                if let set = noti.object as? Set<PathFinder.Point> {
                    paintingPoint = set
                }
            }
            NotificationCenter.default.addObserver(forName: .paintingFinish, object: nil, queue: nil) { noti in
                if let set = noti.object as? Set<PathFinder.Point> {
                    paintingPoint = set
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        paintingPoint = nil
                    }
                }
            }
        })
        .frame(width: screenWidth, height: screenWidth, alignment: .center)
        .padding(0)

    }
}


