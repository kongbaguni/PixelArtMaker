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
    return 500
    #else
    guard let s = UIScreen.screens.first?.bounds.size else {
        return 350
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
    var layers:[LayerModel] {
        StageManager.shared.stage?.layers ?? []
    }
    @State var isShowSelectLayerOnly = false
    @State var colors:[[Color]]
    @State var undoCount = 0
    @State var redoCount = 0

    @State private var timer: Timer?
    @State var isLongPressing = false
    

    @State var isShowSaveView = false
    @State var isShowLoadView = false
    @State var isShowSigninView = false
    
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
    
    init() {
        StageManager.shared.initStage(size: pixelSize)
        let stage = StageManager.shared.stage!
        colors = stage.selectedLayer.colors
    }
        
    func paint(target:CGPoint, color:Color) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        let cc = colors[idx.1][idx.0]
        
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
            if colors[ni.1][ni.0] == cc {
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
        if idx.0 < colors.count && idx.0 >= 0 {
            if idx.1 < colors[idx.0].count && idx.1 >= 0 {
                colors[idx.1][idx.0] = color
            }
        }
        StageManager.shared.stage?.change(colors: colors)
        if let stage = StageManager.shared.stage {
            undoCount = stage.history.count
            redoCount = stage.redoHistory.count
        }
    }
    
    func erase(target:CGPoint) {
        let idx:(Int,Int) = (Int(target.x), Int(target.y))
        erase(idx: idx)
    }
    
    func erase(idx:(Int,Int)) {
        draw(idx: idx, color: .clear)
    }

    
    var body: some View {
        VStack {
            #if !MAC
            NavigationLink(destination: SigninView(), isActive: $isShowSigninView) {
                
            }
            NavigationLink(destination: SaveView(), isActive: $isShowSaveView) {
                
            }
            NavigationLink(destination: LoadView(), isActive: $isShowLoadView) {
                
            }
            #endif
            
            //MARK: - 드로잉 켄버스
            Canvas { context, size in
                let w = size.width / CGFloat(colors.first?.count ?? 1)
                for (i,layer) in (StageManager.shared.stage?.layers ?? []).enumerated() {
                    for (y,list) in layer.colors.enumerated() {
                        for (x,color) in list.enumerated() {
                            if (i == 0) {
                                context.fill(.init(roundedRect: .init(x: CGFloat(x) * w + 1,
                                                                      y: CGFloat(y) * w + 1,
                                                                      width: w - 2.0,
                                                                      height: w - 2.0),
                                                   cornerSize: .init(width: 4, height: 4)), with: .color(backgroundColor))
                            }

                            if color != .clear {
                                context.fill(.init(roundedRect: .init(x: CGFloat(x) * w + 0.5,
                                                                      y: CGFloat(y) * w + 0.5,
                                                                      width: w - 1.0,
                                                                      height: w - 1.0),
                                                   cornerSize: .zero), with: .color(
                                                    isShowSelectLayerOnly
                                                    ? (i == StageManager.shared.stage?.selectedLayerIndex ? color : .clear)
                                                    : color
                                                   ))
                            }
                            
                        }
                    }

                }
                for rect in [
                    CGRect(x: size.width*0.25 - 0.25, y: 0, width: 0.5, height: size.height),
                    CGRect(x: size.width*0.5 - 0.25, y: 0, width: 0.5, height: size.height),
                    CGRect(x: size.width*0.75 - 0.25, y: 0, width: 0.5, height: size.height),
                    CGRect(x: 0, y: size.height * 0.25 - 0.25, width: size.width, height: 0.5),
                    CGRect(x: 0, y: size.height * 0.5 - 0.25, width: size.width, height: 0.5),
                    CGRect(x: 0, y: size.height * 0.75 - 0.25, width: size.width, height: 0.5)
                ]{
                    context.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(.green))
                }
                context.stroke(Path(roundedRect: .init(
                    x: pointer.x * w,
                    y: pointer.y * w,
                    width: pw, height: pw), cornerRadius: 0), with: .color(.k_pointer))
                
            }
            .padding(10)
            .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                print(value.location)
                let idx = getIndex(location: value.location)
                pointer = .init(x: idx.0, y: idx.1)
                #if MAC
                draw(idx: idx, color: selectedColor)
                #endif
            }))
                .frame(width: screenWidth, height: screenWidth, alignment: .center)
            
            Toggle(isOn: $isShowSelectLayerOnly) {
                Text.title_select_Layer_only
            }.padding(20)

            Spacer()

            HStack {
                //MARK: - 미리보기
                NavigationLink(destination: {
                  LayerEditView()
                }, label: {
                    Canvas { context,size in
                        for layer in layers {
                            for (y, list) in layer.colors.enumerated() {
                                for (x,color) in list.enumerated() {
                                    context.fill(.init(roundedRect: .init(x: CGFloat(x),
                                                                          y: CGFloat(y),
                                                                          width: 1,
                                                                          height: 1),
                                                       cornerSize: .zero), with: .color(color))
                                }
                            }
                        }
                    }.frame(width: pixelSize.width, height: pixelSize.height, alignment: .leading)
                        .border(.white, width: 1.0).background(backgroundColor)
                })

                Spacer()
                // MARK:  빠렛트
                HStack {
                    ForEach(0..<7) { i in
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
            }.padding(10)

            HStack {
                // MARK: - 옵션 메뉴
                ScrollView {
                    ColorPicker(selection: $backgroundColor) {
                        Text.color_picker_bg_title
                    }.onChange(of: backgroundColor) { value in
                        StageManager.shared.stage?.backgroundColor = value
                    }
                    ForEach(0..<7) { count in
                        ColorPicker(selection: $paletteColors[count]) {
                            Text.color_picker_br_title
                            Text(" \(count + 1)")
                        }
                    }
                }.padding(SwiftUI.EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))

                //MARK: - 포인터 브러시 컨트롤 뷰
                VStack {
                    HStack {
                        // 연필
                        Button {
                        } label : {
                            Image("pencil")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .background(selectedColor)

                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                draw(target: pointer, color: selectedColor)
                            }))
                        //페인트
                        Button {
                        } label : {
                            Image("paint")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .background(selectedColor)
                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                paint(target: pointer, color: selectedColor)
                            }))
                        //지우개
                        Button {
                        } label : {
                            Image("eraser")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .background(.clear)
                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                draw(target: pointer, color: .clear)
                            }))


                    }


                    HStack {

                        Button {
                            StageManager.shared.stage?.undo()
                        } label: {
                            VStack {
                                Text("undo")
                                if redoCount + undoCount > 0 {
                                    ProgressView(value: CGFloat(undoCount) / CGFloat(redoCount + undoCount) )
                                        .frame(width: 50, height: 5, alignment: .center)
                                }
                            }
                        }.frame(width: 50, height: 50, alignment: .center)

                        Button {
                            if isLongPressing {
                                isLongPressing = false
                                timer?.invalidate()
                            }
                            pointer = .init(x: pointer.x, y: pointer.y - 1)
                        } label: {
                            Text("up")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                    print("long press")
                                    self.isLongPressing = true
                                    //or fastforward has started to start the timer
                                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                        pointer = .init(x: pointer.x, y: pointer.y - 1)
                                    })
                                }
                            )

                        Button {
                            StageManager.shared.stage?.redo()
                        } label: {
                            VStack {
                                Text("redo")
                                if redoCount + undoCount > 0 {
                                    ProgressView(value: CGFloat(redoCount) / CGFloat(redoCount + undoCount) )
                                        .frame(width: 50, height: 5, alignment: .center)
                                }
                            }
                        }.frame(width: 50, height: 50, alignment: .center)

                    }

                    HStack {
                        Button {
                            if isLongPressing {
                                isLongPressing = false
                                timer?.invalidate()
                            }
                            pointer = .init(x: pointer.x - 1, y: pointer.y)
                        } label: {
                            Text("left")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                    print("long press")
                                    self.isLongPressing = true
                                    //or fastforward has started to start the timer
                                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                        pointer = .init(x: pointer.x - 1, y: pointer.y)
                                    })
                                }
                            )

                        Button {
                            if isLongPressing {
                                isLongPressing = false
                                timer?.invalidate()
                            }
                            pointer = .init(x: pointer.x, y: pointer.y + 1)
                        } label: {
                            Text("down")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                    print("long press")
                                    self.isLongPressing = true
                                    //or fastforward has started to start the timer
                                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                        pointer = .init(x: pointer.x, y: pointer.y + 1)
                                    })
                                }
                            )

                        Button {
                            if isLongPressing {
                                isLongPressing = false
                                timer?.invalidate()
                            }
                            pointer = .init(x: pointer.x + 1, y: pointer.y)
                        } label: {
                            Text("right")
                        }.frame(width: 50, height: 50, alignment: .center)
                            .background(Color.green)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                    print("long press")
                                    self.isLongPressing = true
                                    //or fastforward has started to start the timer
                                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                        pointer = .init(x: pointer.x + 1, y: pointer.y)
                                    })
                                }
                            )
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
            // MARK: - 네비게이션바 액션시트 메뉴
            .actionSheet(isPresented: $isShowActionSheet) {
                var buttons:[ActionSheet.Button] = []
                if AuthManager.shared.isSignined == false {
                    buttons.append(
                        .default(.menu_signin_title, action: {
                            isShowSigninView = true
                        })
                    )
                } else {
                    buttons.append(.default(.menu_signout_title, action: {
                        AuthManager.shared.signout()
                    }))
                    buttons.append(.default(.menu_save_title, action: {
                        isShowSaveView = true
                    }))
                    buttons.append(.default(.menu_load_title, action: {
                        isShowLoadView = true
                    }))
                }
                buttons.append(
                    .destructive(.clear_all_button_title, action: {
                        isShowClearAlert = true
                    })
                )
                buttons.append(.cancel())

                return ActionSheet(title: Text("menu"), message: nil, buttons: buttons)
            }
            #endif
            
        }
        .alert(isPresented: $isShowClearAlert) {
            Alert(title: Text.clear_alert_title,
                  message: Text.clear_alert_message,
                  primaryButton: .destructive(
                    Text.clear_alert_confirm, action: {
                        StageManager.shared.initStage(size: pixelSize)
                        load()
                    }), secondaryButton: .cancel())
        }
#if MAC
        .background(KeyEventHandling())
#endif
        .onAppear {
            load()
            NotificationCenter.default.addObserver(forName: .layerDataRefresh, object: nil, queue: nil) { noti in
                load()
            }
        }

    }

    func load() {
        if let stage = StageManager.shared.stage {
            colors = stage.selectedLayer.colors
            undoCount = stage.history.count
            redoCount = stage.redoHistory.count
        }

    }
    
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
