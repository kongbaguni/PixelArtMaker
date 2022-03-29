//
//  PixelDrawView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI
import RealmSwift

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
fileprivate struct Point : Hashable {
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    init(point:CGPoint) {
        self.x = Int(point.x)
        self.y = Int(point.y)
    }
    init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    let x:Int
    let y:Int
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
    let s = screenBounds
    
    if s.width > s.height {
        return s.height
    }
    print("scren : \(s.width / s.height)")
    if s.width / s.height > 0.5 && s.width < 500 {
        return 250
    }
    if s.width / s.height > 0.6 && s.width > 800 {
        return 500
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
    var layers:[LayerModel] {
        StageManager.shared.stage?.layers ?? []
    }
    enum ColorSelectMode {
        case foreground
        case background
    }
    enum AlertType {
        case clear
        case delete
    }
    
    @State var previewImage:Image? = nil
    @State var isLoadingAnimated = true
    @State var isLoadingDataFin = false
    @State var isLoadedColorPreset = false
    @State var colorSelectMode:ColorSelectMode = .foreground
    
    @State var isShowSelectLayerOnly = false
    @State var colors:[[Color]]
    @State var undoCount = 0
    @State var redoCount = 0
    
    @State private var timer: Timer?
    @State var isLongPressing = false
    
    
    @State var isShowColorPresetView = false
    @State var isShowSaveView = false
    @State var isShowLoadView = false
    @State var isShowShareListView = false
    @State var isShowSigninView = false
    
    @State var isShowActionSheet = false
    @State var isShowAlert = false
    @State var alertType:AlertType = .clear
    
    @State var paletteColors:[Color] = [.red,.orange,.yellow,.green,.blue,.purple,.clear]
    @State var forgroundColor:Color = .red
    
    @State var backgroundColor:Color = .white {
        didSet {
            if StageManager.shared.stage?.changeBgColor(color: backgroundColor) == true {
                undoCount = StageManager.shared.stage?.history.count ?? 0
                redoCount = 0
            }
        }
    }
    
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
    
    var selectedParentIndex:Int? {
        switch colorSelectMode {
        case .foreground:
            for (idx,color) in paletteColors.enumerated() {
                if forgroundColor == color {
                    return idx
                }
            }
        case .background:
            for (idx,color) in paletteColors.enumerated() {
                if backgroundColor == color {
                    return idx
                }
            }
        }
        return nil
    }
    
    init() {
        StageManager.shared.initStage(size: pixelSize)
        let stage = StageManager.shared.stage!
        colors = stage.selectedLayer.colors
    }
    
    func changeColor(target:CGPoint, color:Color) {
        let idx:Point = .init(point: target)
        /** 최초 선택 컬러*/
        var result = Set<Point>()
        let cc = colors[idx.y][idx.x]
        for (i,list) in colors.enumerated() {
            for (r,color) in list.enumerated() {
                if cc == color {
                    result.insert(.init(x: r, y: i))
                }
            }
        }
        
        for point in result {
            colors[point.y][point.x] = color
        }
        refreshStage()
    }
    
    func paint(target:CGPoint, color:Color) {
        let idx:Point = .init(point: target)
        /** 최초 선택 컬러*/
        let cc = colors[idx.y][idx.x]
        
        func getNextIdxs(idx:Point)->Set<Point> {
            var nextIdxs:[Point] {
                return [
                    .init(x: idx.x, y: idx.y+1),
                    .init(x: idx.x, y: idx.y-1),
                    .init(x: idx.x+1, y: idx.y),
                    .init(x: idx.x-1, y: idx.y),
                ]
            }
            var result = Set<Point>()
            for next in nextIdxs {
                if next.x < 0 || next.y < 0 || next.y >= colors.count || next.x >= colors[0].count {
                    continue
                }
                if colors[next.y][next.x] == cc {
                    result.insert(next)
                }
            }
            return result
        }
        
        var list = getNextIdxs(idx: idx)
        var test = true
        while test {
            let count = list.count
            for idx in list {
                for new in getNextIdxs(idx: idx) {
                    list.insert(new)
                }
            }
            if count == list.count {
                test = false
            }
        }
        colors[idx.y][idx.x] = color
        for i in list {
            colors[i.y][i.x] = color
        }
        refreshStage()
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
        refreshStage()
    }
    
    private func refreshStage() {
        StageManager.shared.stage?.change(colors: colors)
        StageManager.shared.stage?.backgroundColor = backgroundColor
        StageManager.shared.stage?.forgroundColor = forgroundColor
        if let stage = StageManager.shared.stage {
            undoCount = stage.history.count
            redoCount = stage.redoHistory.count
        }
        StageManager.shared.saveTemp {
            StageManager.shared.stage?.getImage(size: .init(width: 320, height: 320), complete: { image in
                previewImage = image
            })
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
            NavigationLink(destination: SigninView(), isActive: $isShowSigninView) {
                
            }
            NavigationLink(destination: SaveView(), isActive: $isShowSaveView) {
                
            }
            NavigationLink(destination: LoadView(), isActive: $isShowLoadView) {
                
            }
            NavigationLink(destination: ColorPresetView(), isActive: $isShowColorPresetView) {
                
            }
            NavigationLink(destination: PublicShareListView(), isActive: $isShowShareListView) {
                
            }
            
            //MARK: - 드로잉 켄버스
            ZStack {
            Canvas { context, size in
                func draw() {
                    let w = size.width / CGFloat(colors.first?.count ?? 1)
                    for (i,layer) in (StageManager.shared.stage?.layers ?? []).enumerated() {
                        context.blendMode = .init(rawValue: layer.blendMode.rawValue)
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
                    context.stroke(Path(roundedRect: .init(
                        x: pointer.x * w,
                        y: pointer.y * w,
                        width: pw, height: pw), cornerRadius: 0), with: .color(.k_pointer))
                    context.stroke(Path(roundedRect: .init(
                        x: pointer.x * w + 1,
                        y: pointer.y * w + 1,
                        width: pw - 2, height: pw - 2), cornerRadius: 0), with: .color(.k_pointer2))
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
            .padding(10)
            .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                print(value.location)
                let idx = getIndex(location: value.location)
                pointer = .init(x: idx.0, y: idx.1)
                if isLongPressing {
                    isLongPressing = false
                    timer?.invalidate()
                }
            }))
            .frame(width: screenWidth, height: screenWidth, alignment: .center)
                if isLoadingDataFin == false {
                    ActivityIndicator(isAnimating: $isLoadingAnimated, style: .large).frame(width: screenWidth, height: screenWidth, alignment: .center)
                }
            }
            HStack {
                //MARK: - 레이어 토글
                Toggle(isOn: $isShowSelectLayerOnly) {
                    Text.title_select_Layer_only
                }.padding(20)
                //MARK:  미리보기
                NavigationLink(destination: {
                    LayerEditView()
                }, label: {
                    if let img = previewImage {
                        img.resizable().frame(width: 40, height: 40, alignment: .center)
                    }
                }).padding(20)
            }
            
            //            Spacer()
            
            HStack {
                // MARK: -  빠렛트
                VStack {
                    Button {
                        colorSelectMode = .foreground
                    } label: {
                        Text("").frame(width: 28, height: 15, alignment: .center)
                            .background(forgroundColor)
                    }.border(Color.white, width: colorSelectMode == .foreground ? 2 : 0)
                    
                    Button {
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
                HStack {
                    ForEach(0..<7) { i in
                        Button {
                            switch colorSelectMode {
                            case .foreground:
                                forgroundColor = paletteColors[i]
                            case .background:
                                backgroundColor = paletteColors[i]
                            }
                            
                        } label: {
                            Spacer().frame(width: 26, height: 32, alignment: .center)
                                .background(paletteColors[i])
                        }
                        .border(.white, width: colorSelectMode == .foreground
                                ? forgroundColor == paletteColors[i] ? 5.0 : 0.5
                                : backgroundColor == paletteColors[i] ? 5.0 : 0.5
                        )
                        .padding(1)
                    }
                    
                    Button {
                        isShowColorPresetView = true
                    } label : {
                        Image("more")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                        
                    }
                    
                }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            }.padding(10)
            
            HStack {
                //MARK: - 포인터 브러시 컨트롤 뷰
                VStack {
                    HStack {
                        // 연필
                        Button {
                        } label : {
                            Image("pencil")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                            
                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                draw(target: pointer, color: forgroundColor)
                            }))
                        //페인트
                        Button {
                        } label : {
                            Image("paint")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                paint(target: pointer, color: forgroundColor)
                            }))
                        
                        Button {
                        } label : {
                            Image("paint2")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                changeColor(target: pointer, color: forgroundColor)
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
                        //지우개
                        Button {
                        } label : {
                            Image("spoid")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                                .background(.clear)
                        }.frame(width: 50, height: 50, alignment: .center)
                            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
                                if let color = StageManager.shared.stage?.selectedLayer.colors[Int(pointer.y)][Int(pointer.x)] {
                                    forgroundColor = color
                                }
                            }))
                        
                        
                    }
                    
                    
                    HStack {
                        //MARK: - undo
                        Button {
                            StageManager.shared.stage?.undo()
                            StageManager.shared.saveTemp {
                                
                            }
                            if isLongPressing {
                                isLongPressing = false
                                timer?.invalidate()
                            }
                        } label: {
                            VStack {
                                Text("undo")
                                if redoCount + undoCount > 0 {
                                    ProgressView(value: CGFloat(undoCount) / CGFloat(redoCount + undoCount) )
                                        .frame(width: 50, height: 5, alignment: .center)
                                } else {
                                    ProgressView(value: 0)
                                        .frame(width: 50, height: 5, alignment: .center)
                                }
                            }
                        }
                        .frame(width: 50, height: 50, alignment: .center)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                print("long press")
                                self.isLongPressing = true
                                //or fastforward has started to start the timer
                                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                    StageManager.shared.stage?.undo()
                                })
                            }
                        )
                        .padding(20)
                        
                        //MARK: - 화살표 컨트롤러
                        VStack {
                            Button {
                                if isLongPressing {
                                    isLongPressing = false
                                    timer?.invalidate()
                                }
                                pointer = .init(x: pointer.x, y: pointer.y - 1)
                            } label: {
                                Image("arrow_up")
                                    .resizable()
                                    .frame(width: 50, height: 50, alignment: .center)
                            }.frame(width: 50, height: 50, alignment: .center)
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
                            HStack {
                                Button {
                                    if isLongPressing {
                                        isLongPressing = false
                                        timer?.invalidate()
                                    }
                                    pointer = .init(x: pointer.x - 1, y: pointer.y)
                                } label: {
                                    Image("arrow_left")
                                        .resizable()
                                        .frame(width: 50, height: 50, alignment: .center)
                                }.frame(width: 50, height: 50, alignment: .center)
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
                                    Image("arrow_down")
                                        .resizable()
                                        .frame(width: 50, height: 50, alignment: .center)
                                }.frame(width: 50, height: 50, alignment: .center)
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
                                    Image("arrow_right")
                                        .resizable()
                                        .frame(width: 50, height: 50, alignment: .center)
                                }.frame(width: 50, height: 50, alignment: .center)
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
                        }
                        
                        
                        
                        //MARK: - redo
                        Button {
                            StageManager.shared.stage?.redo()
                            StageManager.shared.saveTemp {
                                
                            }
                            if isLongPressing {
                                isLongPressing = false
                                timer?.invalidate()
                            }
                        } label: {
                            VStack {
                                Text("redo")
                                if redoCount + undoCount > 0 {
                                    ProgressView(value: CGFloat(redoCount) / CGFloat(redoCount + undoCount) )
                                        .frame(width: 50, height: 5, alignment: .center)
                                } else {
                                    ProgressView(value: 0)
                                        .frame(width: 50, height: 5, alignment: .center)
                                    
                                }
                            }
                        }
                        .frame(width: 50, height: 50, alignment: .center)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                print("long press")
                                self.isLongPressing = true
                                //or fastforward has started to start the timer
                                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                    StageManager.shared.stage?.redo()
                                })
                            }
                        )
                        .padding(20)
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
                    buttons.append(.default(.menu_public_load_title, action : {
                        isShowShareListView = true
                    }))
                    if StageManager.shared.stage?.documentId != nil {
                        buttons.append(.destructive(Text.menu_delete_title, action: {
                            alertType = .delete
                            isShowAlert = true
                            
                        }))
                    }
                }
                
                buttons.append(.destructive(Text.clear_all_button_title, action: {
                    alertType = .clear
                    isShowAlert = true
                }))
                buttons.append(.cancel())
                return ActionSheet(title: Text("menu"), message: nil, buttons: buttons)
            }
            
            
        }
        
        .alert(isPresented: $isShowAlert)  {
            switch alertType {
            case .clear:
                return Alert(title: Text.clear_alert_title,
                             message: Text.clear_alert_message,
                             primaryButton: .destructive(
                                Text.clear_alert_confirm, action: {
                                    isLoadingDataFin = false
                                    StageManager.shared.deleteTemp { isSucess in
                                        StageManager.shared.initStage(size: pixelSize)
                                        load()
                                        isLoadingDataFin = true
                                    }
                                }), secondaryButton: .cancel())
            case .delete:
                return Alert(title: Text.menu_delete_alert_title,
                             message: Text.menu_delete_alert_message,
                             primaryButton: .destructive(
                                Text.menu_delete_alert_confirm, action: {
                                    isLoadingDataFin = false
                                    StageManager.shared.delete { isSucess in
                                        if isSucess {
                                            StageManager.shared.loadList { list in
                                                isLoadingDataFin = true
                                                StageManager.shared.initStage(size: pixelSize)
                                                load()
                                            }
                                        } else {
                                            isLoadingDataFin = false
                                        }
                                    }
                                }), secondaryButton: .cancel())
            }
        }
        .frame(width: screenBounds.width,
               height: screenBounds.width > 500 ? screenBounds.height : CGFloat.leastNormalMagnitude,
               alignment: .center)
        
#if MAC
        .background(KeyEventHandling())
#endif
        .onAppear {
            //MARK: - onAppear
            if let color = Color.lastSelectColors {
                DispatchQueue.main.async {
                    if isLoadedColorPreset == false {
                        paletteColors = color
                        forgroundColor = color.first!
                        StageManager.shared.stage?.paletteColors = color
                        StageManager.shared.stage?.forgroundColor = forgroundColor
                        StageManager.shared.stage?.backgroundColor = backgroundColor
                        isLoadedColorPreset = true
                        forgroundColor = color.first!
                        
                        StageManager.shared.loadTemp { _ in
                            isLoadingDataFin = true
                            load()
                        }
                        
                    }
                }
            }
            if isLoadedColorPreset == false {
                StageManager.shared.loadList { result in
                    
                }
            }
            load()
            NotificationCenter.default.addObserver(forName: .authDidSucessed, object: nil, queue: nil) { noti in
                isLoadingDataFin = true
                load()
            }
            NotificationCenter.default.addObserver(forName: .layerDataRefresh, object: nil, queue: nil) { noti in
                load()
            }
            NotificationCenter.default.addObserver(forName: .layerblendModeDidChange, object: nil, queue: nil) { noti in
                refreshStage()
            }
        }
        
    }
    
    func load() {        
        if let stage = StageManager.shared.stage {
            forgroundColor = stage.forgroundColor
            backgroundColor = stage.backgroundColor
            colors = stage.selectedLayer.colors
            undoCount = stage.history.count
            redoCount = stage.redoHistory.count
            paletteColors = stage.paletteColors
            stage.getImage(size: .init(width: 320, height: 320)) { image in
                previewImage = image
            }
        }
        
    }
    
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
