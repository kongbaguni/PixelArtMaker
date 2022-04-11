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
    let googleAd = GoogleAd()
    
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
    enum ZoomMode {
        case none
        case zoom
        case offset
    }
    @State var zoomMode:ZoomMode = .none
    @State var zoomScale = 0
    @State var zoomOffset:(x:Int,y:Int) = (x:0,y:0)
    var zoomFrame:(width:Int,height:Int) {
        let size:CGSize = StageManager.shared.stage?.canvasSize ?? .zero
        return (width:Int(size.width) - zoomScale * 2, height: Int(size.height) - zoomScale * 2)
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
    
    func makeSideMenuView(geomentryWidth:CGFloat)->SideMenuView {
        return SideMenuView(isShowSigninView: $isShowSigninView,
                     alertType: $alertType,
                     isShowAlert: $isShowAlert,
                     isShowProfileView: $isShowProfileView,
                     isShowInAppPurches: $isShowInAppPurches,
                     isShowSaveView: $isShowSaveView,
                     isShowLoadView: $isShowLoadView,
                     isShowShareListView: $isShowShareListView,
                     geomentryWidth: geomentryWidth)

    }
    
    func makeCanvasView(screenWidth:CGFloat)->CanvasView {
        return CanvasView(pointer: $pointer,
                   isShowMenu: $isShowMenu,
                   isLoadingAnimated: $isLoadingAnimated,
                   isLongPressing: $isLongPressing,
                   timer: $timer,
                   colors: colors,
                   isLoadingDataFin: isLoadingDataFin,
                   isShowSelectLayerOnly: isShowSelectLayerOnly,
                   screenWidth: screenWidth,
                   backgroundColor: backgroundColor,
                   layers: layers,
                   zoomMode: zoomMode,
                   zoomFrame: zoomFrame,
                   zoomOffset: zoomOffset
        )
    }
    
    func makeLayerToolView()->LayerToolView {
        return LayerToolView(isShowSelectLayerOnly: $isShowSelectLayerOnly,
                      selectedLayerIndex: StageManager.shared.stage?.selectedLayerIndex ?? 0,
                      toastMessage: $toastMessage,
                      isShowToast: $isShowToast,
                      previewImage: previewImage,
                      googleAd: googleAd,
                      layerCount: StageManager.shared.stage?.layers.count ?? 0,
                      isShowInAppPurches: $isShowInAppPurches
        )
    }
    
    func makePalleteView()->PaletteView {
        return PaletteView(forgroundColor: $forgroundColor,
                    backgroundColor: $backgroundColor,
                    colorSelectMode: $colorSelectMode,
                    undoCount: $undoCount,
                    redoCount: $redoCount,
                    isShowMenu: isShowMenu,
                    paletteColors: paletteColors,
                    isShowColorPresetView: $isShowColorPresetView
        )
    }
    
    func makeDrawingToolView()->DrawingToolView {
        return DrawingToolView(
            zoomMode: $zoomMode,
            colors: $colors,
            forgroundColor: $forgroundColor,
            undoCount: $undoCount,
            redoCount: $redoCount,
            toastMessage: $toastMessage,
            isShowToast: $isShowToast,
            previewImage: $previewImage,
            pointer: pointer,
            backgroundColor: backgroundColor)
    }
    
    func makeArrowToolView()->ArrowToolView {
        return ArrowToolView(zoomMode: $zoomMode,
                      toastMessage: $toastMessage,
                      isShowToast: $isShowToast,
                      isLongPressing: $isLongPressing,
                      timer: $timer,
                      pointer: $pointer,
                      zoomOffset: $zoomOffset,
                      zoomScale: $zoomScale,
                      zoomFrame: zoomFrame,
                      isShowMenu: isShowMenu,
                      redoCount: redoCount,
                      undoCount: undoCount)
    }
    
    var body: some View {
        GeometryReader { geomentry in
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
            
                
            
            
            if geomentry.size.height > geomentry.size.width {
                ZStack(alignment: .leading) {
                    if isShowMenu {
                        makeSideMenuView(geomentryWidth: geomentry.size.width)
                    }

                    VStack(alignment: .leading) {
                        makeCanvasView(screenWidth: screenWidth)
                        Spacer()

                        if isShowMenu == false {
                            makeLayerToolView()

                            if zoomMode == .none {
                                makePalleteView()
                                .padding(SwiftUI.EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
                            }
                            
                            HStack {
                                //MARK: - 포인터 브러시 컨트롤 뷰
                                VStack {
                                    makeDrawingToolView()
                                    makeArrowToolView()
                                    
                                }.padding(20)
                            }
                        }
                    }
                    .opacity(isShowMenu ? 0.2 : 1.0)
                }
                
            } else {
                ZStack(alignment: .leading) {
                    if isShowMenu {
                        //MARK: - Side menu
                        makeSideMenuView(geomentryWidth: geomentry.size.height)
                    }
                    HStack {
                        if isShowMenu {
                            Spacer()
                        }
                        makeCanvasView(screenWidth: geomentry.size.height)
                        
                        VStack {
                            if isShowMenu == false {
                                makeLayerToolView()
                                
                                if zoomMode == .none {
                                    makePalleteView().padding(SwiftUI.EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
                                }
                                
                                HStack {
                                    VStack {
                                        makeDrawingToolView()
                                        makeArrowToolView()
                                    }.padding(20)
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    withAnimation {
                        isShowMenu.toggle()
                    }
                    
                } label : {
                    Image(systemName: "line.3.horizontal")
                }
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
