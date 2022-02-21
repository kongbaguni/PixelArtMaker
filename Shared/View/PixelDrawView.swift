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
    #if MAC
    return 300
    #else
    guard let s = UIScreen.screens.first?.bounds.size else {
        return 300
    }
    if s.width > s.height {
        return s.height
    }
    return s.width
    #endif
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
    @State var isShowActionSheet = false
    @State var isShowClearAlert = false
    @State var paletteColors:[Color] = [.red,.orange,.yellow,.green,.blue,.purple,.clear]
    @State var selectedColor:Color = .red
    
    
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
    
    func paint(target:CGPoint, color:Color) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        let cc = data.colors[idx.1][idx.0]
        
        var list:[(Int,Int)] {
            var result:[(Int,Int)] = []
            //* * *
            //* 0 *
            //* * *
            if idx.1 - 1 >= 0 && idx.0 - 1 >= 0{
                result.append((idx.0 - 1, idx.1 - 1))
            }
            if idx.0 - 1 >= 0 {
                result.append((idx.0 - 1, idx.1))
            }
            if idx.0 - 1 >= 0 && idx.1 + 1 < Int(pixelSize.width) {
                result.append((idx.0 - 1, idx.1 + 1))
            }
            if idx.1 - 1 >= 0 {
                result.append((idx.0, idx.1 - 1))
            }
            if idx.1 + 1 < Int(pixelSize.width) {
                result.append((idx.0, idx.1 + 1))
            }
            if idx.0 + 1 < Int(pixelSize.height) && idx.1 - 1 >= 0{
                result.append((idx.0 + 1, idx.1 - 1))
            }
            if idx.0 + 1 < Int(pixelSize.height) {
                result.append((idx.0 + 1, idx.1))
            }
            if idx.0 + 1 < Int(pixelSize.height) && idx.1 + 1 < Int(pixelSize.width) {
                result.append((idx.0 + 1, idx.1 + 1))
            }
            return result
        }
        
        for ni in list {
            if data.colors[ni.1][ni.0] == cc {
                draw(idx: ni, color: color)
            }
        }
        draw(idx: idx, color: color)
        
    }
    func draw(target:CGPoint, color: Color) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        draw(idx: idx, color: color)
    }
        
    func draw(idx:(Int,Int), color:Color) {
        if idx.0 < data.colors.count && idx.0 >= 0 {
            if idx.1 < data.colors[idx.0].count && idx.1 >= 0 {
                data.colors[idx.1][idx.0] = color
            }
        }
    }
    
    func erase(target:CGPoint) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        erase(idx: idx)
    }
    
    func erase(idx:(Int,Int)) {
        if idx.0 < data.colors.count && idx.0 >= 0 {
            if idx.1 < data.colors[idx.0].count && idx.1 >= 0 {                        data.colors[idx.1][idx.0] = .clear
            }
        }
    }

    
    var body: some View {
        VStack {
            //MARK: - 드로잉 켄버스
            Canvas { context, size in
                
                let w = size.width / CGFloat(data.colors.first?.count ?? 1)
                for (y,list) in data.colors.enumerated() {
                    for (x,color) in list.enumerated() {
                        context.fill(.init(roundedRect: .init(x: CGFloat(x) * w + 1,
                                                              y: CGFloat(y) * w + 1,
                                                              width: w - 2.0,
                                                              height: w - 2.0),
                                           cornerSize: .init(width: 4, height: 4)), with: .color(backgroundColor))

                        context.fill(.init(roundedRect: .init(x: CGFloat(x) * w + 0.5,
                                                              y: CGFloat(y) * w + 0.5,
                                                              width: w - 1.0,
                                                              height: w - 1.0),
                                           cornerSize: .zero), with: .color(color))
                    }
                }
                context.stroke(Path(roundedRect: .init(
                    x: pointer.x * w,
                    y: pointer.y * w,
                    width: pw, height: pw), cornerRadius: 0), with: .color(.k_pointer))
                
            }.gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                print(value.location)
                let idx = getIndex(location: value.location)
                pointer = .init(x: idx.0, y: idx.1)
            }))
                .frame(width: screenWidth, height: screenWidth, alignment: .center)
                .onAppear {
                    StageManager.shared.initStage(size: pixelSize)
                    data = StageManager.shared.stage.selectedLayer
                }
            //미리보기
            HStack {
                Canvas { context,size in
                    for (y,list) in data.colors.enumerated() {
                        for (x,color) in list.enumerated() {
                            context.fill(.init(roundedRect: .init(x: CGFloat(x),
                                                                  y: CGFloat(y),
                                                                  width: 1,
                                                                  height: 1),
                                               cornerSize: .zero), with: .color(color))
                        }
                    }
                    
                }.frame(width: pixelSize.width, height: pixelSize.height, alignment: .leading)
                    .border(.white, width: 1.0).background(backgroundColor)
                // MARK: - 빠렛트
                HStack {
                    ForEach(0..<paletteColors.count) { i in
                        Button {
                            selectedColor = paletteColors[i]
                        } label: {
                            Spacer().frame(width: 32, height: 32, alignment: .center)
                                .background(paletteColors[i])
                        }
                        .border(.white, width: selectedColor == paletteColors[i] ? 5.0 : 1.0)
                        .padding(2)
                    }
                }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                Spacer()
            }

            HStack {
                // MARK: - 옵션 메뉴
                ScrollView {
                    ColorPicker(selection: $backgroundColor) {
                        Text.color_picker_bg_title
                    }
                    ForEach(0..<paletteColors.count) { count in
                        ColorPicker(selection: $paletteColors[count]) {
                            Text.color_picker_br_title
                            Text(" \(count + 1)")
                        }
                    }
                }.padding(SwiftUI.EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                
                //MARK: - 포인터 브러시 컨트롤 뷰
                VStack {
                    HStack {
                        Button {
                            draw(target: pointer, color: selectedColor)
                        } label : {
                            Image("pencil")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .background(selectedColor)
                        }.frame(width: 50, height: 50, alignment: .center)
                        
                        Button {
                            paint(target: pointer, color: selectedColor)
                        } label : {
                            Image("paint")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .background(selectedColor)
                        }.frame(width: 50, height: 50, alignment: .center)

                    }
                    
                    HStack {
                        Button {
                            pointer = .init(x: pointer.x, y: pointer.y - 1)
                        } label: {
                            Text("up")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                    }
                    HStack {
                        Button {
                            pointer = .init(x: pointer.x - 1, y: pointer.y)
                        } label: {
                            Text("left")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                        
                        Button {
                            pointer = .init(x: pointer.x, y: pointer.y + 1)
                        } label: {
                            Text("down")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                        
                        Button {
                            pointer = .init(x: pointer.x + 1, y: pointer.y)
                        } label: {
                            Text("right")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                    }
                    
                }.padding(20)
            }
        }
        .toolbar {
            Button {
                isShowActionSheet = true
            } label : {
                Text("menu")
            }
            #if !MAC
            .actionSheet(isPresented: $isShowActionSheet) {
                ActionSheet(title: Text("menu"), message: nil, buttons: [
                    .default(.clear_all_button_title, action: {
                        isShowClearAlert = true
                    }),
                    .cancel()
                ])
            }
            #endif
            
        }
        .alert(isPresented: $isShowClearAlert) {
            Alert(title: Text.clear_alert_title,
                  message: Text.clear_alert_message,
                  primaryButton: .destructive(
                    Text.clear_alert_confirm, action: {
                        data.clear()
                        
                    }), secondaryButton: .cancel())
        }
    }
    
    
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
