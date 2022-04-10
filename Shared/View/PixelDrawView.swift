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



fileprivate var pixelSize:CGSize { StageManager.shared.canvasSize }

struct PixelDrawView: View {
    var layers:[LayerModel] {
        StageManager.shared.stage?.layers ?? []
    }
    
    enum AlertType {
        case clear
        case delete
    }
    @State var isShowMenu = false
    @State var previewImage:Image? = nil
    @State var isLoadingAnimated = true
    @State var isLoadingDataFin = false
    @State var isLoadedColorPreset = false
    @State var colorSelectMode:PaletteView.ColorSelectMode = .foreground
    
    @State var isShowSelectLayerOnly = false
    @State var colors:[[Color]]
    @State var undoCount = 0
    @State var redoCount = 0
    
    @State private var timer: Timer?
    @State var isLongPressing = false
    
    @State var toastMessage = ""
    @State var isShowToast = false
    @State var isShowColorPresetView = false
    @State var isShowSaveView = false
    @State var isShowLoadView = false
    @State var isShowShareListView = false
    @State var isShowSigninView = false
    @State var isShowProfileView = false
    @State var isShowNewCanvasView = false
    @State var isShowInAppPurches = false
    
    @State var isShowAlert = false
    @State var alertType:AlertType = .clear
    
    @State var paletteColors:[Color] = [.red,.orange,.yellow,.green,.blue,.purple,.clear]
    @State var forgroundColor:Color = .red
    
    @State var previewUpdateTimmer:Timer? = nil
    @State var backgroundColor:Color = .white {
        didSet {
            if StageManager.shared.stage?.changeBgColor(color: backgroundColor) == true {
                if let imgData = StageManager.shared.stage?.makeImageDataValue(size: Consts.previewImageSize) {
                    previewImage = Image(uiImage: UIImage(data: imgData)!)
                }
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
        if StageManager.shared.stage == nil {
            StageManager.shared.initStage(canvasSize: StageManager.shared.canvasSize)
        }
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
        StageManager.shared.saveTemp { error in
            if let err = error {
                toastMessage = err.localizedDescription
                isShowToast = true
            } else {
                StageManager.shared.stage?.getImage(size: Consts.previewImageSize, complete: { image in
                    previewImage = image
                })
            }
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
        
        
        GeometryReader { geomentry in
            ZStack(alignment: .trailing) {
                if isShowMenu {
                    //MARK: - Side menu
                    SideMenuView(isShowSigninView: $isShowSigninView,
                                 alertType: $alertType,
                                 isShowAlert: $isShowAlert,
                                 isShowProfileView: $isShowProfileView,
                                 isShowInAppPurches: $isShowInAppPurches,
                                 isShowSaveView: $isShowSaveView,
                                 isShowLoadView: $isShowLoadView,
                                 isShowShareListView: $isShowShareListView,
                                 geomentryWidth: geomentry.size.width)
                }
                VStack(alignment: .leading) {
                    
                    //MARK: - 드로잉 켄버스
                    CanvasView(pointer: $pointer,
                               isShowMenu: $isShowMenu,
                               isLoadingAnimated: $isLoadingAnimated,
                               isLongPressing: $isLongPressing,
                               timer: $timer,
                               colors: colors,
                               isLoadingDataFin: isLoadingDataFin,
                               isShowSelectLayerOnly: isShowSelectLayerOnly,
                               screenWidth: screenWidth,
                               backgroundColor: backgroundColor,
                               layers: layers)
                    Spacer()
                    if isShowMenu == false {
                        HStack {
                            //MARK: - 레이어 토글
                            Toggle(isOn: $isShowSelectLayerOnly) {
                                Text.title_select_Layer_only
                            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            //MARK:  미리보기
                            NavigationLink(destination: {
                                LayerEditView()
                            }, label: {
                                if let img = previewImage {
                                    img.resizable().frame(width: 64, height: 64, alignment: .center)
                                }
                            })
                        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        
                        //            Spacer()
                        HStack {
                            // MARK: -  빠렛트
                            PaletteView(forgroundColor: $forgroundColor,
                                        backgroundColor: $backgroundColor,
                                        colorSelectMode: $colorSelectMode,
                                        undoCount: $undoCount,
                                        redoCount: $redoCount,
                                        isShowMenu: isShowMenu,
                                        paletteColors: paletteColors,
                                        isShowColorPresetView: $isShowColorPresetView
                            )
                            
                        }.padding(SwiftUI.EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
                        
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
                                        if isShowMenu {
                                            return
                                        }
                                        StageManager.shared.stage?.undo()
                                        StageManager.shared.saveTemp { error in
                                            toastMessage = error?.localizedDescription ?? ""
                                            isShowToast = error != nil
                                        }
                                    } label: {
                                        VStack {
                                            Image(systemName:"arrow.uturn.backward.circle").imageScale(.large)
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
                                    .padding(20)
                                    
                                    
                                    //MARK: - 화살표 컨트롤러
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
                                    }
                                    
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
                                    
                                    //MARK: - redo
                                    Button {
                                        StageManager.shared.stage?.redo()
                                        StageManager.shared.saveTemp { error in
                                            toastMessage = error?.localizedDescription ?? ""
                                            isShowToast = error != nil
                                        }
                                        
                                    } label: {
                                        VStack {
                                            Image(systemName:"arrow.uturn.forward.circle").imageScale(.large)
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
                                    .padding(20)
                                }
                                
                            }.padding(20)
                        }
                    }
                    
                    //MARK: - 네비게이션
                    Group {
                        NavigationLink(destination: NewCanvasView(), isActive: $isShowNewCanvasView) {
                            
                        }
                        NavigationLink(destination: InAppPurchesView(), isActive: $isShowInAppPurches) {
                            
                        }
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
                        if let id = AuthManager.shared.userId {
                            NavigationLink(destination: ProfileView(uid: id, haveArtList: true, editable: true), isActive: $isShowProfileView) {
                                
                            }
                        }
                    }
                }
                .opacity(isShowMenu ? 0.2 : 1.0)
            }
            
        }
        .toolbar {
            Button {
                withAnimation {
                    isShowMenu.toggle()
                }
                
            } label : {
                Image(systemName: "line.3.horizontal")
            }
            
            
        }
        
        .alert(isPresented: $isShowAlert)  {
            switch alertType {
            case .clear:
                return Alert(title: Text.clear_alert_title,
                             message: Text.clear_alert_message,
                             primaryButton: .destructive(
                                Text.clear_alert_confirm, action: {
                                    isLoadingDataFin = true
                                    isShowNewCanvasView = true
                                }), secondaryButton: .cancel())
            case .delete:
                return Alert(title: Text.menu_delete_alert_title,
                             message: Text.menu_delete_alert_message,
                             primaryButton: .destructive(
                                Text.menu_delete_alert_confirm, action: {
                                    isLoadingDataFin = false
                                    let size = StageManager.shared.canvasSize
                                    
                                    StageManager.shared.delete { error in
                                        if let err = error {
                                            isLoadingDataFin = false
                                            toastMessage = err.localizedDescription
                                            isShowToast = true
                                        } else {                                    
                                            StageManager.shared.loadList { list in
                                                isLoadingDataFin = true
                                                StageManager.shared.initStage(canvasSize: size)
                                                load()
                                            }
                                        }
                                    }
                                }), secondaryButton: .cancel())
            }
        }
        //        .frame(width: screenBounds.width,
        //               height: screenBounds.width > 500 ? screenBounds.height : CGFloat.leastNormalMagnitude,
        //               alignment: .center)
        
#if MAC
        .background(KeyEventHandling())
#endif
        .toast(message: toastMessage, isShowing: $isShowToast, duration: 4)
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
    
    @State var _oldBgColor:Color? = nil
    
    func load() {
        if let stage = StageManager.shared.stage {
            forgroundColor = stage.forgroundColor
            backgroundColor = stage.backgroundColor
            colors = stage.selectedLayer.colors
            undoCount = stage.history.count
            redoCount = stage.redoHistory.count
            paletteColors = stage.paletteColors
            stage.getImage(size: Consts.previewImageSize) { image in
                previewImage = image
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [self] timer in
            if _oldBgColor != backgroundColor {
                if let imageData = StageManager.shared.stage?.makeImageDataValue(size: Consts.previewImageSize) {
                    previewImage = Image(uiImage: UIImage(data: imageData)!)
                    print("update preview with timmer")
                }
                _oldBgColor = backgroundColor
            }
            
        })
    }
    
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
