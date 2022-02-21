//
//  PixelDrawView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI
enum Position:String {
    case 왼쪽상단 = "lt"
    case 가운대상단 = "ct"
    case 오른쪽상단 = "tt"
    case 왼쪽중앙 = "lc"
    case 중앙 = "cc"
    case 오른쪽중앙 = "tc"
    case 왼쪽하단 = "lb"
    case 중앙하단 = "cb"
    case 오른쪽하단 = "tb"
}

fileprivate func getPosition(location:CGPoint, targetSize:CGSize)->Position? {
    var txt = ""
    if location.x < targetSize.width / 3 {
        txt = "l"
    } else if location.x < targetSize.width / 3 * 2 {
        txt = "c"
    } else if location.x < targetSize.width  {
        txt = "t"
    }
    
    if location.y < targetSize.height / 3  {
        txt += "t"
    }
    else if location.y < targetSize.height / 3 * 2 {
        txt += "c"
    }
    else if location.y < targetSize.height  {
        txt += "b"
    }
    
    return Position(rawValue: txt)
}

fileprivate var screenWidth:CGFloat {
    guard let s = UIScreen.screens.first?.bounds.size else {
        return 300
    }
    if s.width > s.height {
        return s.height
    }
    return s.width
}

fileprivate var pw:CGFloat {
    return screenWidth / pixelSize.width
}

fileprivate func getIndex(location:CGPoint)->(Int,Int) {
    let x = Int(location.x / pw)
    let y = Int(location.y / pw)
    return (x,y)
}

fileprivate let pixelSize = CGSize(width: 32, height: 32)

fileprivate let padSize = CGSize(width: 200, height: 200)

struct PixelDrawView: View {
    @State var data:LayerModel = LayerModel(size: pixelSize) {
        didSet {
            StageManager.shared.stage.change(layer: data)
        }
    }
    @State var selectedColor:Color = .black
    @State var backgroundColor:Color = .white
    @State var pointer:CGPoint = .zero {
        didSet {
            if pointer.x < 0 {
                pointer.x = 0
            }
            if pointer.y < 0 {
                pointer.y = 0
            }
            if pointer.x >= pixelSize.width {
                pointer.x = pixelSize.width - 1
            }
            if pointer.y >= pixelSize.height {
                pointer.y = pixelSize.height - 1
            }
        }
    }
    
    @State var touchPosition:Position? = nil
    
    func draw(target:CGPoint) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        draw(idx: idx)
    }
    
    func draw(idx:(Int,Int)) {
        if idx.0 < data.colors.count && idx.0 >= 0 {
            if idx.1 < data.colors[idx.0].count && idx.1 >= 0 {
                data.colors[idx.1][idx.0] = selectedColor
            }
        }
    }
    
    var body: some View {
        VStack {
            Canvas { context, size in
                let w = size.width / CGFloat(data.colors.first?.count ?? 1)
                for (y,list) in data.colors.enumerated() {
                    for (x,color) in list.enumerated() {
                        context.fill(.init(roundedRect: .init(x: CGFloat(x) * w,
                                                              y: CGFloat(y) * w,
                                                              width: w,
                                                              height: w),
                                           cornerSize: .zero), with: .color(color))
                    }
                }
                context.stroke(Path(roundedRect: .init(
                    x: pointer.x * w,
                    y: pointer.y * w,
                    width: pw, height: pw), cornerRadius: 0), with: .color(.yellow))
                
            }.gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                print(value.location)
                let idx = getIndex(location: value.location)
                draw(idx: idx)
                pointer = .init(x: idx.0, y: idx.1)
            }))
                .frame(width: screenWidth, height: screenWidth, alignment: .center)
                .border(Color.white, width: 1.0)
                .background(backgroundColor)
                .onAppear {
                    data = StageManager.shared.stage.selectedLayer
                }
            
            ColorPicker(selection: $backgroundColor) {
                Text("Background Color")
            }
            ColorPicker(selection: $selectedColor) {
                Text("Brush Color")
            }
            Button("clear") {
                data.clear()
            }
            Canvas { context,size in
                var point:CGPoint? {
                    let w = padSize.width / 3
                    let h = padSize.height / 3
                    switch touchPosition {
                    case .왼쪽상단:
                        return .zero
                    case .가운대상단:
                        return .init(x: w, y: 0)
                    case .오른쪽상단:
                        return .init(x: w * 2, y: 0)
                    case .왼쪽중앙:
                        return .init(x: 0, y: h)
                    case .오른쪽중앙:
                        return .init(x: w * 2, y: h)
                    case .왼쪽하단:
                        return .init(x: 0, y: h * 2)
                    case .중앙하단:
                        return .init(x: w, y: h * 2)
                    case .오른쪽하단:
                        return .init(x: w * 2, y: h * 2)
                    case .중앙:
                        return .init(x: w, y: h)
                    default:
                        return nil
                    }
                }

                if let p = point {
                    context.fill(Path(roundedRect: .init(origin: p, size: .init(width: padSize.width / 3, height: padSize.height / 3)), cornerSize: .zero), with: .color(.yellow))
                }
            }
            .frame(width: padSize.width, height: padSize.height, alignment: .leading)
            .background(Color.gray)
            .border(.white, width: 1.0)
            .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                        .onChanged({ value in
                let position = getPosition(location: value.location, targetSize: padSize)
                switch position {
                case .왼쪽상단:
                    pointer = .init(x: pointer.x - 1, y: pointer.y - 1)
                case .가운대상단:
                    pointer = .init(x: pointer.x, y: pointer.y - 1)
                case .오른쪽상단:
                    pointer = .init(x: pointer.x + 1, y: pointer.y - 1)
                case .왼쪽중앙:
                    pointer = .init(x: pointer.x - 1, y: pointer.y)
                case .오른쪽중앙:
                    pointer = .init(x: pointer.x + 1, y: pointer.y)
                case .왼쪽하단:
                    pointer = .init(x: pointer.x - 1, y: pointer.y + 1)
                case .중앙하단:
                    pointer = .init(x: pointer.x , y: pointer.y + 1)
                case .오른쪽하단:
                    pointer = .init(x: pointer.x + 1 , y: pointer.y + 1)
                case .중앙:
                    draw(target: pointer)
                default:
                    break
                }
                
                touchPosition = position
            })
            )
        }
    }
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
